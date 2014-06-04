# encoding: UTF-8
require 'spec_helper'

describe ReviewerSessionsController, type: :controller do

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
      Conference.stubs(:current).returns(@conference)
      @session = FactoryGirl.build(:session)
      Session.stubs(:for_reviewer).returns(Session)
      Session.stubs(:order).returns(Session)
      Session.stubs(:for_audience_level).returns(Session)
      Session.stubs(:for_session_type).returns(Session)
      Session.stubs(:page).returns([@session])
    end

    it "should assign tracks for current conference" do
      get :index
      (assigns(:tracks) - Track.for_conference(Conference.current)).should be_empty
    end

    it "should assign audience levels for current conference" do
      get :index
      (assigns(:audience_levels) - Conference.current.audience_levels).should be_empty
    end

    it "should assign session types for current conference" do
      get :index
      (assigns(:session_types) - Conference.current.session_types).should be_empty
    end

    it "should filter sessions" do
      Session.expects(:for_audience_level).with('1').returns(Session)
      Session.expects(:for_session_type).with('2').returns(Session)

      get :index, :session_filter => {:audience_level_id => '1', :session_type_id => '2'}
    end

    context "during early review phase" do
      before(:each) do
        @conference.expects(:in_early_review_phase?).returns(true)
      end

      it "should list sessions for reviewer" do
        Session.expects(:for_reviewer).with(@reviewer.user, @conference).returns(Session)
        get :index
        assigns(:sessions).should == [@session]
      end

      it "should order sessions for reviewer from less reviewed to more reviewed" do
        Session.expects(:order).with('sessions.early_reviews_count ASC').returns(Session)
        get :index
        assigns(:sessions).should == [@session]
      end
    end

    context "during final review phase" do
      before(:each) do
        @conference.expects(:in_early_review_phase?).returns(false)
        @conference.expects(:in_final_review_phase?).returns(true)
      end

      it "should list sessions for reviewer" do
        Session.expects(:for_reviewer).with(@reviewer.user, @conference).returns(Session)
        get :index
        assigns(:sessions).should == [@session]
      end

      it "should order sessions for reviewer from less reviewed to more reviewed" do
        Session.expects(:order).with('sessions.final_reviews_count ASC').returns(Session)
        get :index
        assigns(:sessions).should == [@session]
      end
    end

    context "outside of review phase" do
      before(:each) do
        @conference.expects(:in_early_review_phase?).returns(false)
        @conference.expects(:in_final_review_phase?).returns(false)
      end

      it "should return no sessions" do
        get :index
        assigns(:sessions).should be_empty
      end
    end
  end
end
