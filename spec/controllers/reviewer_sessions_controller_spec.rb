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
      Conference.stubs(:current).returns(@conference)
      @session = FactoryGirl.build(:session)
      Session.stubs(:for_reviewer).returns(Session)
      Session.stubs(:order).returns(Session)
      Session.stubs(:page).returns([@session])
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
