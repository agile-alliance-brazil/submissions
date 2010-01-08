class Session < ActiveRecord::Base
  attr_accessible :title, :summary, :description, :mechanics, :benefits,
                  :target_audience, :audience_limit, :author_id, :experience

  belongs_to :author, :class_name => 'User'
  
  validates_presence_of :title, :summary, :description, :benefits, :target_audience,
                        :author_id, :experience
  
end