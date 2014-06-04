# encoding: UTF-8
require 'spec_helper'

describe ReviewersHelper, type: :helper do
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

  it "should build hash with reviewers when reviewer is anonymous" do
    early_review = FactoryGirl.create(:early_review)
    reviewer = FactoryGirl.create(:reviewer, user: early_review.reviewer)
    reviwers, comments = helper.build_hash_with_reviewers_and_comments([early_review], Conference.current)
    reviwers[early_review].should == "Avaliador 1"
  end

  it "should build hash with reviewers when reviewer is not anonymous" do
    early_review = FactoryGirl.create(:early_review)
    reviewer = FactoryGirl.create(:reviewer, sign_reviews: true, user: early_review.reviewer)
    reviwers, comments = helper.build_hash_with_reviewers_and_comments([early_review], Conference.current)
    reviwers[early_review].should == reviewer.user.full_name 
  end

  it "should build hash with reviewers when there are anonymous and not anonymous reviewers" do
    early_review1 = FactoryGirl.create(:early_review)
    reviewer1 = FactoryGirl.create(:reviewer, sign_reviews: false, user: early_review1.reviewer)
    
    early_review2 = FactoryGirl.create(:early_review)
    reviewer2 = FactoryGirl.create(:reviewer, sign_reviews: true, user: early_review2.reviewer)
    
    early_review3 = FactoryGirl.create(:early_review)
    reviewer3 = FactoryGirl.create(:reviewer, sign_reviews: false, user: early_review3.reviewer)

    reviewers, comments = helper.build_hash_with_reviewers_and_comments([early_review1, early_review2, early_review3], Conference.current)
    reviewers[early_review1].should == "Avaliador 1"
    reviewers[early_review2].should == reviewer2.user.full_name
    reviewers[early_review3].should == "Avaliador 3"
  end

end
