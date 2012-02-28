# encoding: UTF-8
require 'spec_helper'

describe Conference do
  context "associations" do
    it { should have_many :tracks }
  end

  it "should overide to_param with year" do
    Conference.find_by_year(2010).to_param.should == "2010"
    Conference.find_by_year(2011).to_param.should == "2011"
    Conference.find_by_year(2012).to_param.should == "2012"
  end
end
