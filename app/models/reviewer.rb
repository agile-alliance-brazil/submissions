# encoding: UTF-8
# frozen_string_literal: true

class Reviewer < ActiveRecord::Base
  attr_trimmed :user_username

  attr_autocomplete_username_as :user

  belongs_to :user
  belongs_to :conference
  has_many :preferences, dependent: :destroy
  has_many :accepted_preferences, -> { where('preferences.accepted = ?', true) }, class_name: 'Preference'

  accepts_nested_attributes_for :preferences

  validates :conference_id, presence: true, existence: true
  validates :user_id, existence: true, uniqueness: { scope: :conference_id }

  scope(:for_conference, ->(c) { where(conference_id: c.id) })
  scope(:for_user, ->(u) { where(user_id: u.id) })
  scope(:accepted, -> { where(state: :accepted) })
  scope(:for_track, ->(track_id) { joins(:accepted_preferences).where(preferences: { track_id: track_id }) })

  def self.user_reviewing_conference?(user, conference)
    !for_user(user).for_conference(conference).accepted.empty?
  end

  state_machine initial: :created do
    after_transition on: :invite do |reviewer|
      EmailNotifications.reviewer_invitation(reviewer).deliver_now
    end

    after_transition on: :accept do |reviewer|
      reviewer.user.add_role :reviewer
      reviewer.user.save(validate: false)
    end

    event :invite do
      transition %i[created invited] => :invited
    end

    event :accept do
      transition invited: :accepted
    end

    event :reject do
      transition invited: :rejected
    end

    state :accepted do
      validate do |reviewer|
        if reviewer.preferences.select(&:accepted?).empty?
          reviewer.errors.add(:base, :preferences)
        end
      end
      validates :reviewer_agreement, acceptance: true
    end
  end

  after_create do
    invite
  end

  after_destroy do
    if Reviewer.where(user_id: user.id).count.zero?
      user.remove_role :reviewer
      user.save(validate: false)
    end
  end

  def can_review?(track)
    !user.organized_tracks(conference).include?(track)
  end

  def display_name(index = nil)
    return user.full_name if sign_reviews
    "#{I18n.t('formtastic.labels.reviewer.user_id')} #{index}".strip
  end

  def early_reviews
    user.early_reviews.for_conference(conference)
  end

  def final_reviews
    user.final_reviews.for_conference(conference)
  end

  def reviews
    user.reviews.for_conference(conference)
  end
end
