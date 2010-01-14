class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :track_id, :session_type_id, :duration_mins,
                  :experience

  belongs_to :author, :class_name => 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  
  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :audience_level_id, :author_id, :track_id, :session_type_id,
                        :experience, :duration_mins
  
  validates_presence_of :mechanics, :if => :workshop?
  validates_inclusion_of :duration_mins, :in => [45, 90], :allow_blank => true
  
  private
  def workshop?
    self.session_type == SessionType.find_by_title('session_types.workshop.title')
  end
end