class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :second_author_username, :track_id,
                  :session_type_id, :duration_mins, :experience,
                  :keyword_list
  
  acts_as_taggable_on :keywords

  belongs_to :author, :class_name => 'User'
  belongs_to :second_author, :class_name => 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  
  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :audience_level_id, :author_id, :track_id, :session_type_id,
                        :experience, :duration_mins, :keyword_list
  
  validates_presence_of :mechanics, :if => :workshop?
  validates_inclusion_of :duration_mins, :in => [45, 90], :allow_blank => true
  validates_each :second_author_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.second_author.nil?
    record.errors.add(attr, :same_author) if record.second_author == record.author
  end
  validates_each :duration_mins, :if => :experience_report? do |record, attr, value|
    record.errors.add(attr, :experience_report_duration) if value != 45
  end
  validates_each :session_type_id, :if => :experience_report? do |record, attr, value|
    record.errors.add(attr, :experience_report_session_type) if record.session_type != SessionType.find_by_title('session_types.talk.title')
  end
  validates_each :author_id, :on => :update do |record, attr, value|
    record.errors.add(attr, :constant) if record.author_id_changed?
  end
  
  named_scope :for_user, lambda { |u| {:conditions => ['author_id = ? OR second_author_id = ?', u.to_i, u.to_i]}}
  
  def second_author_username
    @second_author_username || second_author.try(:username)
  end
  
  def second_author_username=(username)
    @second_author_username = username
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

  private
  def workshop?
    self.session_type == SessionType.find_by_title('session_types.workshop.title')
  end

  def experience_report?
    self.track == Track.find_by_title('tracks.experience_reports.title')
  end
end