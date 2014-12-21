# encoding: UTF-8
class User < ActiveRecord::Base
  include Authorization

  devise :database_authenticatable, :registerable, :recoverable, :encryptable, :trackable, :validatable

  attr_trimmed    :first_name, :last_name, :username, :email, :twitter_username,
                  :phone, :state, :city, :organization, :website_url, :bio

  has_many :sessions, foreign_key: 'author_id'
  has_many :organizers
  has_many :all_organized_tracks, through: :organizers, source: :track
  has_many :reviewers
  has_many :reviews, foreign_key: 'reviewer_id'
  has_many :early_reviews, foreign_key: 'reviewer_id'
  has_many :final_reviews, foreign_key: 'reviewer_id'
  has_many :votes
  has_many :voted_sessions, through: :votes, source: :session

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  with_options if: :author? do |author|
    author.validates :phone, presence: true, length: { maximum: 100 }, format: { with: /\A[0-9\(\) .\-\+]+\Z/i }
    author.validates :country, presence: true
    author.validates :city, presence: true, length: { maximum: 100 }
    author.validates :bio, presence: true, length: { maximum: 1600 }
    author.validates :state, presence: { if: ->(u) { u.author? && u.in_brazil? } }
  end
  validates :organization, length: { maximum: 100 }, allow_blank: true
  validates :website_url, length: { maximum: 100 }, allow_blank: true
  validates :username, length: { within: 3..30 }, format: { with: /\A\w[\w\.+\-_@ ]+\z/, message: :username_format }, uniqueness: { case_sensitive: false }, constant: { on: :update }
  validates :email, length: { within: 6..100 }, allow_blank: true

  before_validation do |user|
    user.twitter_username = user.twitter_username[1..-1] if user.twitter_username =~ /\A@/
    user.state = '' unless in_brazil?
  end

  scope :search, lambda { |q| where("username LIKE ?", "%#{q}%") }
  

  def organized_tracks(conference)
    Track.joins(:track_ownerships).where(organizers: {
        conference_id: conference.id,
        user_id: self.id
    })
  end

  def preferences(conference)
    Preference.joins(:reviewer).where(reviewers: {
        conference_id: conference.id,
        user_id: self.id
    })
  end

  def reviewer_for conference
    reviewers.for_conference(conference).first
  end

  def sessions_for_conference(conference)
    Session.for_user(self.id).for_conference(conference)
  end

  # TODO: Stop using Conference.current
  # Overriding role check to take current conference into account
  def reviewer_with_conference?
    reviewer_without_conference? && Reviewer.user_reviewing_conference?(self, Conference.current)
  end
  alias_method_chain :reviewer?, :conference

  # TODO: Stop using Conference.current
  # Overriding role check to take current conference into account
  def organizer_with_conference?
    organizer_without_conference? && Organizer.user_organizing_conference?(self, Conference.current)
  end
  alias_method_chain :organizer?, :conference

  def full_name
    [self.first_name, self.last_name].join(' ')
  end

  def to_param
    username.blank? ? super : "#{id}-#{username.parameterize}"
  end

  def in_brazil?
    self.country == "BR"
  end

  def wants_to_submit
    author?
  end

  def wants_to_submit=(wants_to_submit)
    self.add_role('author') if wants_to_submit == '1'
  end

  def has_approved_session?(conference)
    Session.for_user(self.id).for_conference(conference).with_state(:accepted).count > 0
  end
end
