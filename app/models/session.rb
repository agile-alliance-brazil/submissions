class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :second_author_username, :track_id,
                  :session_type_id, :duration_mins, :experience,
                  :keyword_list
  attr_trimmed    :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :experience
  
  acts_as_taggable_on :keywords
  acts_as_commentable

  belongs_to :author, :class_name => 'User'
  belongs_to :second_author, :class_name => 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  
  has_many :reviews
  
  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :audience_level_id, :author_id, :track_id, :session_type_id,
                        :experience, :duration_mins, :keyword_list
  
  validates_presence_of :mechanics, :if => :workshop?
  validates_inclusion_of :duration_mins, :in => [45, 90], :allow_blank => true
  validates_numericality_of :audience_limit, :only_integer => true, :greater_than => 0, :allow_nil => true
  
  validates_length_of :title, :maximum => 100
  validates_length_of :target_audience, :maximum => 200
  validates_length_of [:benefits, :experience], :maximum => 400
  validates_length_of :summary, :maximum => 800
  validates_length_of :description, :maximum => 2400
  validates_length_of :mechanics, :maximum => 2400, :allow_blank => true

  validates_each :keyword_list do |record, attr, value|
    record.errors.add(attr, :too_long, :count => 10) if record.keyword_list.size > 10
  end

  validates_each :second_author_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.second_author.nil?
    record.errors.add(attr, :same_author) if record.second_author == record.author
    record.errors.add(attr, :incomplete) if !record.second_author.try(:author?)
  end
  validates_each :duration_mins, :if => :experience_report? do |record, attr, value|
    record.errors.add(attr, :experience_report_duration) if value != 45
  end
  validates_each :session_type_id, :if => :experience_report? do |record, attr, value|
    record.errors.add(attr, :experience_report_session_type) if record.session_type.try(:title) != 'session_types.talk.title'
  end
  validates_each :author_id, :on => :update do |record, attr, value|
    record.errors.add(attr, :constant) if record.author_id_changed?
  end
  
  named_scope :for_user, lambda { |u|
    {:conditions => ['author_id = ? OR second_author_id = ?', u.to_i, u.to_i]}
  }
  
  named_scope :for_tracks, lambda { |track_ids| 
    {:conditions => ['track_id IN (?)', track_ids]}
  }
  
  named_scope :not_author, lambda { |u|
    {:conditions => ['author_id <> ? AND (second_author_id IS NULL OR second_author_id <> ?)', u.to_i, u.to_i]}
  }
  
  named_scope :reviewed_by, lambda { |u|
    {
      :joins => :reviews,
      :conditions => ['reviewer_id = ?', u.to_i]
    }
  }
  
  named_scope :for_preferences, lambda { |*preferences|
    return {:conditions => '1 = 2'} if preferences.empty?
    clause = preferences.map { |p| "(track_id = ? AND audience_level_id <= ?)" }.join(" OR ")
    args = preferences.map {|p| [p.track_id, p.audience_level_id]}.flatten
    {:conditions => [clause, *args]}
  }
  
  named_scope :incomplete_reviews, lambda { |limit|
    {:conditions => ['reviews_count < ?', limit]}
  }
  
  def self.for_reviewer(user)
    incomplete_reviews(3).
    not_author(user.id).
    without_state(:cancelled).
    for_preferences(*user.preferences).all - reviewed_by(user.id).all
  end
  
  state_machine :initial => :created do
    event :reviewing do
      transition [:created, :in_review] => :in_review
    end

    event :cancel do
      transition [:created, :in_review] => :cancelled
    end
    
    event :tentatively_accept do
      transition :in_review => :pending_confirmation
    end
    
    event :accept do
      transition :pending_confirmation => :accepted
    end

    event :reject do
      transition :pending_confirmation => :rejected
    end
  end
  
  def second_author_username
    @second_author_username || second_author.try(:username)
  end
  
  def second_author_username=(username)
    @second_author_username = username.try(:strip)
    returning @second_author_username do
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

  private
  def workshop?
    self.session_type.try(:title) == 'session_types.workshop.title'
  end

  def experience_report?
    self.track.try(:title) == 'tracks.experience_reports.title'
  end
end