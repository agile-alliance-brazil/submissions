# encoding: UTF-8
class CourseAttendance < ActiveRecord::Base
  belongs_to :course
  belongs_to :attendee, :counter_cache => true

  scope :for, lambda { |c| where('course_id = ?', c.id) }
end
