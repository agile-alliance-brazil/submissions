class CoursePrice < ActiveRecord::Base
  belongs_to :course
  belongs_to :registration_period
end