# encoding: UTF-8
class CoursePrice < ActiveRecord::Base
  belongs_to :course
  belongs_to :registration_period
  
  scope :for, lambda { |period, course| where('registration_period_id = ? AND course_id = ?', period.id, course.id) }
end
