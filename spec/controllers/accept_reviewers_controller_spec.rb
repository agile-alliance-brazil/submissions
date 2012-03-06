# encoding: UTF-8
require 'spec_helper'

describe AcceptReviewersController do
  before(:each) do
    @reviewer = FactoryGirl.create(:reviewer)
    Reviewer.stubs(:find).returns(@reviewer)
    sign_in @reviewer.user
    disable_authorization
  end
  
  describe "with view rendering", :render_views => true do
    render_views
  
    it "show pt should work" do
      get :show, :reviewer_id => @reviewer.id, :locale => :pt
    end
  
    it "show en should work" do
      get :show, :reviewer_id => @reviewer.id, :locale => :en
    end
  end

  it_should_require_login_for_actions :show

  it "show action should render show template" do
    get :show, :reviewer_id => @reviewer.id
    response.should render_template(:show)
  end
  
  it "show action should populate preferences for each track when empty" do
    get :show, :reviewer_id => @reviewer.id
    assigns(:reviewer).preferences.size.should == Track.for_conference(Conference.current).count
  end

  it "show action should keep preferences when already present" do
    @reviewer.preferences.build(:track_id => Track.for_conference(Conference.current).first.id)
    get :show, :reviewer_id => @reviewer.id
    assigns(:reviewer).preferences.size.should == 1
  end
  
  it "show action should only assign audience levels for current conference" do
    get :show, :reviewer_id => @reviewer.id
    (assigns(:audience_levels) - Conference.current.audience_levels).should be_empty
  end
end
