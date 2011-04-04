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
  
  context "price" do
    before :each do
      @course = Factory(:course)
    end
    it "should have price based on date" do
      first = Time.zone.local(2011, 05, 01, 12, 0, 0)
      @course.price(first).should == 990.00
      second = Time.zone.local(2011, 06, 01, 12, 0, 0)
      @course.price(second).should == 1290.00
      third = Time.zone.local(2011, 06, 25, 12, 0, 0)
      @course.price(third).should == 1650.00
    end
  end
end