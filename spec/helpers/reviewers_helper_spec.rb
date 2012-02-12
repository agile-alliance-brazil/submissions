# encoding: UTF-8
require 'spec_helper'

describe ReviewersHelper do
  it "should reply doesnot_review for track without preferences" do
    helper.review_level([], FactoryGirl.build(:track)).should == 'reviewer.doesnot_review'
  end
  
  it "should reply doesnot_review for track with preferences that don't match" do
    track = FactoryGirl.build(:track, :id => 10)
    helper.review_level([FactoryGirl.build(:preference, :track => track)], FactoryGirl.build(:track)).should == 'reviewer.doesnot_review'
  end
  
  it "should reply preference level for track with preferences that match" do
    track = FactoryGirl.build(:track)
    preference = FactoryGirl.build(:preference, :track => track)
    helper.review_level([preference], track).should == preference.audience_level.title
  end
end
