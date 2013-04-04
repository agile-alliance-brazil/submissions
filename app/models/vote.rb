class Vote < ActiveRecord::Base
  VOTE_LIMIT = 5

  attr_accessible :session_id, :user_id, :conference_id

  belongs_to :session
  belongs_to :user
  belongs_to :conference

  validates_presence_of :session_id, :user_id, :conference_id
  validates_existence_of :session, :user, :conference
  validates_uniqueness_of :user_id, :scope => [:session_id, :conference_id]

  validates_each :session_id, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :invalid) if record.session.try(:conference_id) != record.conference_id
  end

  validates_each :user_id, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :author) if record.session.try(:is_author?, record.user)
    record.errors.add(attr, :voter) unless record.user.try(:voter?)
  end

  validate do |record|
    unless Vote.within_limit?(record.user, record.conference)
      record.errors.add(:base, :limit_reached, :count => VOTE_LIMIT)
    end
  end

  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }

  scope :for_user, lambda { |u| where('user_id = ?', u.id) }

  def self.within_limit?(user, conference)
    return false unless user.present? && conference.present?
    self.for_conference(conference).for_user(user).count < VOTE_LIMIT
  end
end
