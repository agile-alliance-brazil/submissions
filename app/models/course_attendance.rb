class CourseAttendance < ActiveRecord::Base
  belongs_to :course
  belongs_to :attendee

  scope :for, lambda { |c| where('course_id = ?', c.id) }
end