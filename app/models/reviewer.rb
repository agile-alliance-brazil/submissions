# encoding: UTF-8
class Reviewer < ActiveRecord::Base
  attr_accessible :user_id, :conference_id, :user_username, :preferences_attributes,
                  :reviewer_agreement, :state_event
  attr_trimmed    :user_username

  attr_autocomplete_username_as :user

  belongs_to :user
  belongs_to :conference
  has_many :preferences, :dependent => :destroy
  has_many :accepted_preferences, :class_name => 'Preference', :conditions => ['preferences.accepted = ?', true]

  accepts_nested_attributes_for :preferences

  validates :conference_id, :presence => true, :existence => true
  validates :user_id, :existence => true, :uniqueness => {:scope => :conference_id}

  scope :for_conference, lambda { |c| where(:conference_id => c.id) }
  scope :for_user, lambda { |u| where(:user_id => u.id) }
  scope :accepted, lambda { where(:state => :accepted) }
  scope :for_track, lambda { |track_id| joins(:accepted_preferences).where(:preferences => {:track_id => track_id}) }

  def self.user_reviewing_conference?(user, conference)
    !self.for_user(user).for_conference(conference).accepted.empty?
  end

  state_machine :initial => :created do
    after_transition :on => :invite do |reviewer|
      EmailNotifications.reviewer_invitation(reviewer).deliver
    end

    after_transition :on => :accept do |reviewer|
      reviewer.user.add_role :reviewer
      reviewer.user.save(:validate => false)
    end

    event :invite do
      transition [:created, :invited] => :invited
    end

    event :accept do
      transition :invited => :accepted
    end

    event :reject do
      transition :invited => :rejected
    end

    state :accepted do
      validate do |reviewer|
        if reviewer.preferences.select {|p| p.accepted?}.empty?
          reviewer.errors.add(:base, :preferences)
        end
      end
      validates :reviewer_agreement, :acceptance => true
    end
  end

  after_create do
    invite
  end

  after_destroy do
    user.remove_role :reviewer
    user.save(:validate =>false)
  end

  def can_review?(track)
    !user.organized_tracks(self.conference).include?(track)
  end
end
