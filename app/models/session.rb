class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_level_id, :audience_limit,
                  :author_id, :second_author_id, :second_author_username,
                  :track_id, :session_type_id, :duration_mins, :experience

  belongs_to :author, :class_name => 'User'
  belongs_to :second_author, :class_name => 'User'
  belongs_to :track
  belongs_to :session_type
  belongs_to :audience_level
  
  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :audience_level_id, :author_id, :track_id, :session_type_id,
                        :experience, :duration_mins
  
  validates_presence_of :mechanics, :if => :workshop?
  validates_inclusion_of :duration_mins, :in => [45, 90], :allow_blank => true
  validates_each :second_author_username, :allow_blank => true do |record, attr, value|
    record.errors.add(:second_author_username, :existence) if record.second_author.nil?
    record.errors.add(:second_author_username, :same_author) if record.second_author == record.author
  end
  
  def second_author_username
    @second_author_username || second_author.try(:username)
  end
  
  def second_author_username=(username)
    @second_author_username = username
    returning @second_author_username do
      unless @second_author_username.blank?
        self.second_author = User.find_by_username(@second_author_username)
      end
    end
  end

  private
  def workshop?
    self.session_type == SessionType.find_by_title('session_types.workshop.title')
  end
end