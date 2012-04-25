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
      @conference = Conference.current
      @session = FactoryGirl.create(:session, :created_at => @conference.presubmissions_deadline - 1.day)
      FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @session.track, :audience_level => @session.audience_level)
    end

    it "should list sessions for reviewer that didn't review them" do
      @conference.expects(:in_early_review_phase?).returns(true)
      get :index
      assigns(:sessions).should == [@session]
    end

    it "should order sessions for reviewer from less reviewed to more reviewed" do
      @conference.expects(:in_early_review_phase?).returns(true)
      @session.update_attribute :early_reviews_count, @conference.presubmissions_deadline - 1.day
      @session.save!
      other_session = FactoryGirl.create(:session, :track => @session.track, :audience_level => @session.audience_level,
                                         :created_at => @conference.presubmissions_deadline - 1.day)
      get :index
      assigns(:sessions).should == [other_session, @session]
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
