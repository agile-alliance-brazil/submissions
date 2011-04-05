class Course < ActiveRecord::Base
  belongs_to :conference
  has_many :course_prices
  
  validates_presence_of :name
  validates_presence_of :full_name
  
  scope :for_conference, lambda {|c| where('conference_id = ?', c.id)}
  
  def price(datetime)
    period = RegistrationPeriod.for(datetime).first
    period.price_for_course(self)
  end
end