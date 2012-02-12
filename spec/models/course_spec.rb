# encoding: UTF-8
# encoding: utf-8
require 'spec_helper'

describe Course do
  context "validations" do
    should_validate_presence_of :name
    should_validate_presence_of :full_name
  end
  
  context "associations" do
    should_belong_to :conference
    should_have_many :course_prices
    should_have_many :course_attendances
  end
  
  describe "price" do
    it "delegates to RegistrationPeriod" do
      course = Course.find_by_name('course.csm.name')
      late = RegistrationPeriod.find_by_title('registration_period.late')
      course.price(late.start_at + 1.day).should == 1650.00
    end
  end

  context "limit reached?" do
    before do
      @cspo = Course.find_by_name('course.cspo.name')
      CourseAttendance.stubs(:for).with(@cspo).returns(CourseAttendance)
    end

    it "under limit should be allowed" do
      CourseAttendance.expects(:count).returns(10)
      @cspo.should_not have_reached_limit
    end

    it "when limit reached should not be allowed" do
      CourseAttendance.expects(:count).returns(30)
      @cspo.should have_reached_limit
    end

    it "over limit should not be allowed" do
      CourseAttendance.expects(:count).returns(31)
      @cspo.should have_reached_limit
    end
  end

end
