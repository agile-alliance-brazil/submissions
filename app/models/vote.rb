# encoding: UTF-8
# frozen_string_literal: true

class Vote < ActiveRecord::Base
  VOTE_LIMIT = 5

  belongs_to :session
  belongs_to :user
  belongs_to :conference

  validates :session_id, existence: true, same_conference: true
  validates :user_id, existence: true, voter: true, uniqueness: { scope: %i[session_id conference_id] }
  validates :conference_id, existence: true

  validate do |record|
    unless Vote.within_limit?(record.user, record.conference)
      record.errors.add(:base, :limit_reached, count: VOTE_LIMIT)
    end
  end

  scope(:for_conference, ->(c) { where(conference_id: c.id) })
  scope(:for_user, ->(u) { where(user_id: u.id) })

  def self.within_limit?(user, conference)
    return false unless user.present? && conference.present?
    for_conference(conference).for_user(user).count < VOTE_LIMIT
  end
end
