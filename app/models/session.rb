# encoding: UTF-8
class Session < ActiveRecord::Base
  attr_trimmed    :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :prerequisites, :experience

  acts_as_taggable_on :keywords
  acts_as_commentable

  attr_autocomplete_username_as :second_author

  belongs_to :author, class_name: 'User'
  belongs_to :second_author, class_name: 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  belongs_to :conference

  has_many :early_reviews
  has_many :final_reviews
  has_many :votes

  has_one :review_decision

  validates :title, presence: true, length: { maximum: 100 }
  validates :summary, presence: true, length: { maximum: 800 }
  validates :description, presence: true, length: { maximum: 2400 }
  validates :benefits, presence: true, length: { maximum: 400 }
  validates :target_audience, presence: true, length: { maximum: 200 }
  validates :prerequisites, presence: true, length: { maximum: 200 }
  validates :experience, presence: true, length: { maximum: 400 }
  validates :duration_mins, presence: true, session_duration: true
  validates :keyword_list, presence: true, length: { maximum: 10 }
  validates :language, presence: true, inclusion: { in: ['en', 'pt'] }
  validates :mechanics, presence: true, length: { maximum: 2400 }, if: :requires_mechanics?
  validates :audience_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :conference_id, existence: true
  validates :author_id, existence: true, constant: { on: :update }
  validates :track_id, presence: true, existence: true, same_conference: true
  validates :session_type_id, presence: true, existence: true, same_conference: true
  validates :audience_level_id, presence: true, existence: true, same_conference: true
  validates :second_author_username, second_author: true, allow_blank: true

  scope :for_conference, ->(conference) { where(conference_id: conference.id)}
  scope :for_user, ->(user) { where('author_id = ? OR second_author_id = ?', user.to_i, user.to_i) }
  scope :for_tracks, ->(track_ids) { where(track_id: track_ids) }
  scope :for_audience_level, ->(audience_level_id) { where(audience_level_id: audience_level_id) }
  scope :for_session_type, ->(session_type_id) { where(session_type_id: session_type_id) }
  scope :with_incomplete_final_reviews, -> { where('final_reviews_count < ?', 3) }
  scope :with_incomplete_early_reviews, -> { where('early_reviews_count < ?', 1) }
  scope :submitted_before, ->(date) { where('sessions.created_at <= ?', date) }
  scope :not_author, ->(u) {
    where('author_id <> ? AND (second_author_id IS NULL OR second_author_id <> ?)', u.to_i, u.to_i)
  }
  scope :not_reviewed_by, ->(user, review_type) {
    joins("LEFT OUTER JOIN reviews ON sessions.id = reviews.session_id AND reviews.type = '#{review_type}'").
      where('reviews.reviewer_id IS NULL OR reviews.reviewer_id <> ?', user.id).
      group("sessions.id").
      having("count(reviews.id) = sessions.#{review_type.underscore.pluralize}_count")
  }
  scope :for_preferences, ->(*preferences) {
    return none if preferences.empty?
    clause = preferences.map { |p| "(track_id = ? AND audience_level_id <= ?)" }.join(" OR ")
    args = preferences.map {|p| [p.track_id, p.audience_level_id]}.flatten
    where(clause, *args)
  }
  scope :with_outcome, ->(outcome) {
    includes(:review_decision).where(review_decisions: { outcome_id: outcome.id, published: false })
  }

  def self.for_review_in(conference)
    sessions = for_conference(conference).without_state(:cancelled)
    if conference.in_early_review_phase?
      sessions.submitted_before(conference.presubmissions_deadline + 3.hours)
    else
      sessions
    end
  end

  def self.for_reviewer(user, conference)
    sessions = for_review_in(conference).
      not_author(user.id).
      for_preferences(*user.preferences(conference)).
      not_reviewed_by(user, conference.in_early_review_phase? ? 'EarlyReview' : 'FinalReview')
    if conference.in_final_review_phase?
      sessions.with_incomplete_final_reviews
    else
      sessions
    end
  end

  def self.not_reviewed_count_for(conference)
    Session.for_conference(conference).where(state: 'created').count
  end

  def self.not_decided_count_for(conference)
    Session.for_conference(conference).where(state: 'in_review').count
  end

  def self.without_decision_count_for(conference)
    Session.for_conference(conference).where(state: ['pending_confirmation', 'rejected']).
      joins('left outer join (
        SELECT session_id, count(*) AS cnt
        FROM review_decisions
        GROUP BY session_id
      ) AS review_decision_count
      ON review_decision_count.session_id = sessions.id').where('review_decision_count.cnt <> 1').count
  end

  state_machine initial: :created do
    event :reviewing do
      transition [:created, :in_review] => :in_review
    end

    event :cancel do
      transition [:created, :in_review] => :cancelled
    end

    event :tentatively_accept do
      transition [:rejected, :in_review] => :pending_confirmation
    end

    event :accept do
      transition pending_confirmation: :accepted
    end

    event :reject do
      transition [:pending_confirmation, :in_review] => :rejected
    end

    state :accepted do
      validates :author_agreement, acceptance: { accept: true }
    end

    state :rejected do
      validates :author_agreement, acceptance: { accept: true }
    end

  end

  def to_param
    title.blank? ? super : "#{id}-#{title.parameterize}"
  end

  def authors
    [author, second_author].compact
  end

  def is_author?(user)
    authors.include?(user)
  end

  def respond_to?(method_sym, include_private = false)
    method_is_session_type_based?(method_sym) ||
      super
  end

  def method_missing(method_sym, *arguments, &block)
    if method_is_session_type_based?(method_sym)
      # Responds to 'lightning_talk?' if there is a session type with that title
      self.session_type.try(:send, method_sym, *arguments, &block)
    else
      super
    end
  end

  private
  def method_is_session_type_based?(method_sym)
    SessionType.all_titles.
      map {|title| "#{title}?"}.
      include?(method_sym.to_s)
  end

  def requires_mechanics?
    (respond_to?(:workshop?) && workshop?) ||
      (respond_to?(:hands_on?) && hands_on?)
  end
end
