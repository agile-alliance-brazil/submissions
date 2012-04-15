# encoding: UTF-8
require 'spec_helper'

describe ReviewerSessionsController do

  before(:each) do
    @reviewer ||= FactoryGirl.create(:reviewer)
    sign_in @reviewer.user
    disable_authorization
  end

  describe "with view rendering", :render_views => true do
    render_views

    it "index should work" do
      get :index
    end
  end

  it_should_require_login_for_actions :index

  describe "#index" do
    before(:each) do
      @session = FactoryGirl.create(:session)
      FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @session.track, :audience_level => @session.audience_level)
      @conference = Conference.current
    end

    it "should list sessions for reviewer with incomplete early reviews" do
      @conference.expects(:in_early_review_phase?).returns(true)
      @session.update_attribute :created_at, @conference.presubmissions_deadline - 1.day
      @session.save!
      get :index
      assigns(:sessions).should == [@session]
    end

    it "should hide sessions for reviewer with complete early reviews" do
      @conference.expects(:in_early_review_phase?).returns(true)
      FactoryGirl.create(:early_review, :session => @session)
      get :index
      assigns(:sessions).should == []
    end

    it "should list sessions for reviewer with incomplete final reviews" do
      @conference.expects(:in_early_review_phase?).returns(false)
      get :index
      assigns(:sessions).should == [@session]
    end

    it "should hide sessions for reviewer with complete final reviews" do
      @conference.expects(:in_early_review_phase?).returns(false)
      FactoryGirl.create_list(:final_review, 3, :session => @session)
      get :index
      assigns(:sessions).should == []
    end
  end
end
