require 'spec_helper'

describe CourseAttendance do
  context "associations" do
    should_belong_to :course
    should_belong_to :attendee
  end
end