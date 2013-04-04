class Vote < ActiveRecord::Base
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
    record.errors.add(attr, :invalid) if record.session.try(:is_author?, record.user)
  end

  VOTE_LIMIT = 5

  validate do |record|
    if record.conference.present? && record.user.present?
      vote_count = Vote.for_conference(record.conference).for_user(record.user).count
      record.errors.add(:base, :limit_reached, :count => vote_count) if vote_count == VOTE_LIMIT
    end
  end

  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }
  scope :for_user, lambda { |u| where('user_id = ?', u.id) }

  def self.vote_in_session(user, session)
    where(:user_id => user.id, :session_id => session.id).first
  end
end
