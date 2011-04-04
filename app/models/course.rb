class Course < ActiveRecord::Base
  belongs_to :conference
  has_many :course_prices
  
  validates_presence_of :name
  validates_presence_of :full_name
  
  def price(datetime)
    prices = course_prices.select {|p| p.registration_period.include? datetime}
    prices.size > 0 ? prices.first.value : nil
  end
end