# encoding: UTF-8
require 'spec_helper'

describe CourseAttendance do
  context "associations" do
    it { should belong_to :course }
    it { should belong_to :attendee }
  end
end
