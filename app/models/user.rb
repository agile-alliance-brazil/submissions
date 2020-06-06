# frozen_string_literal: true

class User < ApplicationRecord
  include Authorization

  devise :database_authenticatable, :registerable, :recoverable, :encryptable, :trackable, :validatable

  attr_trimmed    :first_name, :last_name, :username, :email, :twitter_username,
                  :phone, :state, :city, :organization, :website_url, :bio

  has_many :sessions, foreign_key: 'author_id', dependent: :restrict_with_exception, inverse_of: :author
  has_many :organizers, dependent: :destroy
  has_many :all_organized_tracks, through: :organizers, source: :track, dependent: :nullify, inverse_of: :organizers
  has_many :reviewers, dependent: :destroy
  has_many :reviews, foreign_key: 'reviewer_id', dependent: :restrict_with_exception, inverse_of: :reviewer
  has_many :early_reviews, foreign_key: 'reviewer_id', dependent: :restrict_with_exception, inverse_of: :reviewer
  has_many :final_reviews, foreign_key: 'reviewer_id', dependent: :restrict_with_exception, inverse_of: :reviewer
  has_many :votes, dependent: :destroy
  has_many :voted_sessions, through: :votes, source: :session, dependent: :destroy, inverse_of: :votes
  has_many :comments, dependent: :nullify
  has_many :review_decisions, dependent: :restrict_with_exception, inverse_of: :organizer
  has_many :review_feedbacks, dependent: :restrict_with_exception, inverse_of: :author

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  with_options if: :author? do
    validates :phone, presence: true, length: { maximum: 100 }, format: { with: /\A[0-9() .\-+]+\Z/i }
    validates :country, presence: true
    validates :city, presence: true, length: { maximum: 100 }
    validates :bio, presence: true, length: { maximum: 1600 }
    validates :state, presence: { if: -> { author? && in_brazil? } }
  end
  validates :organization, length: { maximum: 100 }, allow_blank: true
  validates :website_url, length: { maximum: 100 }, allow_blank: true
  validates :username, length: { within: 3..30 }, format: { with: /\A\w[\w.+\-_@ ]+\z/, message: :username_format }, uniqueness: { case_sensitive: false }, constant: { on: :update }
  validates :email, length: { within: 6..100 }, allow_blank: true

  before_validation do |user|
    user.twitter_username = user.twitter_username[1..-1] if user.twitter_username =~ /\A@/
    user.state = '' unless in_brazil?
  end

  scope(:search, ->(q) { where('username LIKE ?', "%#{q}%") })
  scope(:by_comments, ->(comment_filters) { joins(:comments).includes(:comments).where(comments: comment_filters).group('comments.user_id').order('COUNT(comments.user_id) DESC').order(created_at: :desc) })

  def organized_tracks(conference)
    Track.joins(:track_ownerships).where(organizers: {
                                           conference_id: conference.id,
                                           user_id: id
                                         })
  end

  def preferences(conference)
    Preference.joins(:reviewer).where(reviewers: {
                                        conference_id: conference.id,
                                        user_id: id
                                      })
  end

  def reviewer_for(conference)
    reviewers.for_conference(conference).first
  end

  def sessions_for_conference(conference)
    Session.for_user(id).for_conference(conference)
  end

  def organizer_for_conference(conference)
    organizers.for_conference(conference).first
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
    [first_name, last_name].join(' ')
  end

  def to_param
    username.blank? ? super : "#{id}-#{username.parameterize}"
  end

  def in_brazil?
    country == 'BR'
  end

  def wants_to_submit
    author?
  end

  def wants_to_submit=(wants_to_submit)
    add_role('author') if wants_to_submit == '1'
  end

  def has_approved_session?(conference)
    Session.for_user(id).for_conference(conference).with_state(:accepted).count.positive?
  end
end
