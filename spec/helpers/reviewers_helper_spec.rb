require 'spec/spec_helper'

describe ReviewersHelper do
  it "should reply doesnot_review for track without preferences" do
    helper.review_level([], Factory(:track)).should == 'reviewer.doesnot_review'
  end
  
  it "should reply doesnot_review for track with preferences that don't match" do
    track = Factory(:track, :id => 10)
    helper.review_level([Factory(:preference, :track => track)], Factory(:track)).should == 'reviewer.doesnot_review'
  end
  
  it "should reply preference level for track with preferences that match" do
    track = Factory(:track)
    preference = Factory(:preference, :track => track)
    helper.review_level([preference], track).should == preference.audience_level.title
  end
end