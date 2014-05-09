# encoding: UTF-8
class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :prerequisites, :audience_level_id, :audience_limit,
                  :author_id, :second_author_username, :track_id, :conference_id,
                  :session_type_id, :duration_mins, :experience,
                  :keyword_list, :author_agreement, :image_agreement, :state_event,
                  :language
  attr_trimmed    :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :prerequisites, :experience

  acts_as_taggable_on :keywords
  acts_as_commentable

  attr_autocomplete_username_as :second_author

  belongs_to :author, :class_name => 'User'
  belongs_to :second_author, :class_name => 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  belongs_to :conference

  has_many :early_reviews
  has_many :final_reviews
  has_many :votes

  has_one :review_decision

  validates :title, :presence => true, :length => {:maximum => 100}
  validates :summary, :presence => true, :length => {:maximum => 800}
  validates :description, :presence => true, :length => {:maximum => 2400}
  validates :benefits, :presence => true, :length => {:maximum => 400}
  validates :target_audience, :presence => true, :length => {:maximum => 200}
  validates :prerequisites, :presence => true, :length => {:maximum => 200}
  validates :experience, :presence => true, :length => {:maximum => 400}
  validates :duration_mins, :presence => true, :session_duration => true, :allow_blank => true
  validates :keyword_list, :presence => true, :length => {:maximum => 10}
  validates :language, :presence => true, :inclusion => {:in => ['en', 'pt']}, :allow_blank => true
  validates :mechanics, :presence => true, :length => {:maximum => 2400}, :if => :requires_mechanics?
  validates :audience_limit, :numericality => {:only_integer => true, :greater_than => 0}, :allow_nil => true
  validates :conference_id, :existence => true
  validates :author_id, :existence => true, :constant => { :on => :update }
  validates :track_id, :presence => true, :existence => true, :same_conference => true, :allow_blank => true
  validates :session_type_id, :presence => true, :existence => true, :same_conference => true, :allow_blank => true
  validates :audience_level_id, :presence => true, :existence => true, :same_conference => true, :allow_blank => true
  validates :second_author_username, :second_author => true, :allow_blank => true

  scope :for_conference,     lambda { |conference| where(:conference_id => conference.id)}
  scope :for_user,           lambda { |user| where('author_id = ? OR second_author_id = ?', user.to_i, user.to_i) }
  scope :for_tracks,         lambda { |track_ids| where(:track_id => track_ids) }
  scope :for_audience_level, lambda { |audience_level_id| where(:audience_level_id => audience_level_id) }
  scope :for_session_type,   lambda { |session_type_id| where(:session_type_id => session_type_id) }

  scope :not_author, lambda { |u|
    where('author_id <> ? AND (second_author_id IS NULL OR second_author_id <> ?)', u.to_i, u.to_i)
  }

  scope :not_reviewed_by, lambda { |user, review_type|
    select("sessions.*").
    joins("LEFT OUTER JOIN reviews ON sessions.id = reviews.session_id AND reviews.type = '#{review_type}'").
    where('reviews.reviewer_id IS NULL OR reviews.reviewer_id <> ?', user.id).
    group('sessions.id').
    having("count(reviews.id) = sessions.#{review_type.underscore.pluralize}_count")
  }

  scope :for_preferences, lambda { |*preferences|
    return none if preferences.empty?
    clause = preferences.map { |p| "(track_id = ? AND audience_level_id <= ?)" }.join(" OR ")
    args = preferences.map {|p| [p.track_id, p.audience_level_id]}.flatten
    where(clause, *args)
  }

  scope :none, where('1 = 0')

  scope :with_incomplete_final_reviews, where('final_reviews_count < ?', 3)
  scope :with_incomplete_early_reviews, where('early_reviews_count < ?', 1)
  scope :submitted_before, lambda { |date| where('sessions.created_at <= ?', date) }

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

  state_machine :initial => :created do
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
      transition :pending_confirmation => :accepted
    end

    event :reject do
      transition [:pending_confirmation, :in_review] => :rejected
    end

    state :accepted do
      validates :author_agreement, :acceptance => {:accept => true}
    end

    state :rejected do
      validates :author_agreement, :acceptance => {:accept => true}
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

  SessionType.all_titles.each do |type|
    define_method("#{type}?") do                   # def lightning_talk?
      self.session_type.try(:"#{type}?")           #   self.session_type.try(:lightning_talk?)
    end                                            # end
  end

  private
  def requires_mechanics?
    workshop? || hands_on?
  end
end
