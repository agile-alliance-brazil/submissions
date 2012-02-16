# encoding: UTF-8
require 'spec_helper'

describe CoursePrice do
  context "associations" do
    it { should belong_to :course }
    it { should belong_to :registration_period }
  end
  
  it "should be scopped by course"
end
