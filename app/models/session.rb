# encoding: UTF-8
class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :second_author_username, :track_id, :conference_id,
                  :session_type_id, :duration_mins, :experience,
                  :keyword_list, :author_agreement, :image_agreement, :state_event,
                  :language
  attr_trimmed    :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :experience

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
  has_one :review_decision

  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :audience_level_id, :author_id, :track_id, :session_type_id,
                        :experience, :duration_mins, :keyword_list, :conference_id,
                        :language

  validates_presence_of :mechanics, :if => :requires_mechanics?
  validates_inclusion_of :language, :in => ['en', 'pt'], :allow_blank => true
  validates_numericality_of :audience_limit, :only_integer => true, :greater_than => 0, :allow_nil => true

  validates_length_of :title, :maximum => 100
  validates_length_of :target_audience, :maximum => 200
  validates_length_of [:benefits, :experience], :maximum => 400
  validates_length_of :summary, :maximum => 800
  validates_length_of :description, :maximum => 2400
  validates_length_of :mechanics, :maximum => 2400, :allow_blank => true

  validates_existence_of :conference, :author
  validates_existence_of :track, :session_type, :audience_level, :allow_blank => true

  validates_each :duration_mins, :allow_blank => true do |record, attr, value|
    valid_durations = record.session_type.valid_durations
    error_message = valid_durations.join(" #{I18n.t('generic.or')} ")
    record.errors.add(attr, :session_type_duration, {:valid_durations => error_message}) unless value.in?(valid_durations)
  end

  validates_each :keyword_list do |record, attr, value|
    record.errors.add(attr, :too_long, :count => 10) if record.keyword_list.size > 10
  end

  validates_each :second_author_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.second_author.nil?
    record.errors.add(attr, :same_author) if record.second_author == record.author
    record.errors.add(attr, :incomplete) if record.second_author.present? && !record.second_author.try(:author?)
  end
  validates_each :author_id, :on => :update do |record, attr, value|
    record.errors.add(attr, :constant) if record.author_id_changed?
  end
  validates_each :track_id, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :invalid) if record.track.conference_id != record.conference_id
  end
  validates_each :audience_level_id, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :invalid) if record.audience_level.conference_id != record.conference_id
  end
  validates_each :session_type_id, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :invalid) if record.session_type.conference_id != record.conference_id
  end

  scope :for_conference, lambda { |c| where('conference_id = ?', c.id)}

  scope :for_user, lambda { |u| where('author_id = ? OR second_author_id = ?', u.to_i, u.to_i) }

  scope :for_tracks, lambda { |track_ids| where('track_id IN (?)', track_ids) }

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
      validates_acceptance_of :author_agreement, :accept => true
    end

    state :rejected do
      validates_acceptance_of :author_agreement, :accept => true
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
