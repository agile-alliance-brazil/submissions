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
  end
  
  describe "price" do
    it "delegates to RegistrationPeriod" do
      course = Course.find_by_name('course.csm.name')
      late = RegistrationPeriod.find_by_title('registration_period.late')
      course.price(late.start_at + 1.day).should == 1650.00
    end
  end
end