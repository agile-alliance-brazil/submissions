require 'spec_helper'

describe CoursePrice do
  context "associations" do
    should_belong_to :course
    should_belong_to :registration_period
  end
  
  it "should be scopped by course"
end
