# encoding: UTF-8
class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :second_author_username, :track_id, :conference_id,
                  :session_type_id, :duration_mins, :experience,
                  :keyword_list, :author_agreement, :image_agreement, :state_event
  attr_trimmed    :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :experience

  acts_as_taggable_on :keywords
  acts_as_commentable

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
                        :experience, :duration_mins, :keyword_list, :conference_id

  validates_presence_of :mechanics, :if => :requires_mechanics?
  validates_inclusion_of :duration_mins, :in => [10, 50, 110], :allow_blank => true
  validates_numericality_of :audience_limit, :only_integer => true, :greater_than => 0, :allow_nil => true

  validates_length_of :title, :maximum => 100
  validates_length_of :target_audience, :maximum => 200
  validates_length_of [:benefits, :experience], :maximum => 400
  validates_length_of :summary, :maximum => 800
  validates_length_of :description, :maximum => 2400
  validates_length_of :mechanics, :maximum => 2400, :allow_blank => true

  validates_existence_of :conference, :author
  validates_existence_of :track, :session_type, :audience_level, :allow_blank => true

  validates_each :keyword_list do |record, attr, value|
    record.errors.add(attr, :too_long, :count => 10) if record.keyword_list.size > 10
  end

  validates_each :second_author_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.second_author.nil?
    record.errors.add(attr, :same_author) if record.second_author == record.author
    record.errors.add(attr, :incomplete) if record.second_author.present? && !record.second_author.try(:author?)
  end
  validates_each :duration_mins, :if => :experience_report?, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :experience_report_talk_duration) if record.session_type.try(:title) == 'session_types.talk.title' && value != 50
  end
  validates_each :duration_mins, :if => :lightning_talk? do |record, attr, value|
    record.errors.add(attr, :lightning_talk_duration) if value != 10
  end
  validates_each :duration_mins, :if => :talk?, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :talk_duration) if value != 50
  end
  validates_each :duration_mins, :if => :hands_on?, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :hands_on_duration) if value != 110
  end
  validates_each :session_type_id, :if => :experience_report? do |record, attr, value|
    record.errors.add(attr, :experience_report_session_type) unless ['session_types.talk.title', 'session_types.lightning_talk.title'].include?(record.session_type.try(:title))
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

  scope :not_author, lambda { |u| where('author_id <> ? AND (second_author_id IS NULL OR second_author_id <> ?)', u.to_i, u.to_i) }

  scope :not_reviewed_by, lambda { |u|
    joins('LEFT OUTER JOIN reviews ON sessions.id = reviews.session_id').
    where('reviews.reviewer_id IS NULL OR reviews.reviewer_id <> ?', u.id)
  }

  scope :for_preferences, lambda { |*preferences|
    return where('1 = 2') if preferences.empty?
    clause = preferences.map { |p| "(track_id = ? AND audience_level_id <= ?)" }.join(" OR ")
    args = preferences.map {|p| [p.track_id, p.audience_level_id]}.flatten
    where(clause, *args)
  }

  scope :with_incomplete_final_reviews, where('final_reviews_count < ?', 3)
  scope :with_incomplete_early_reviews, where('early_reviews_count < ?', 1)
  scope :submitted_before, lambda { |date| where('sessions.created_at <= ?', date) }

  def self.for_reviewer(user, conference)
    for_conference(conference).
    not_author(user.id).
    without_state(:cancelled).
    for_preferences(*user.preferences(conference)).
    not_reviewed_by(user)
  end

  def self.incomplete_early_reviews_for(conference)
    with_incomplete_early_reviews.submitted_before(conference.presubmissions_deadline)
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

  def second_author_username
    @second_author_username || second_author.try(:username)
  end

  def second_author_username=(username)
    @second_author_username = username.try(:strip)
    @second_author_username.tap do
      if @second_author_username.blank?
        self.second_author = nil
      else
        self.second_author = User.find_by_username(@second_author_username)
      end
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

  def lightning_talk?
    self.session_type.try(:lightning_talk?)
  end

  def hands_on?
    self.session_type.try(:hands_on?)
  end

  def talk?
    self.session_type.try(:talk?)
  end

  private
  def requires_mechanics?
    session_type.try(:workshop?) || session_type.try(:hands_on?)
  end

  def experience_report?
    track.try(:experience_report?)
  end
end
