# encoding: UTF-8
require 'spec_helper'

describe OrganizerSessionsController do

  before(:each) do
    @organizer = FactoryGirl.create(:organizer)
    sign_in @organizer.user
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
      Session.stubs(:for_conference).returns(Session)
      Session.stubs(:for_tracks).returns(Session)
      Session.stubs(:with_state).returns(Session)
      Session.stubs(:page).returns(Session)
      Session.stubs(:order).returns(Session)
      Session.stubs(:includes).returns([@session])
    end

    it "should assign tracks for current conference" do
      get :index
      (assigns(:tracks) - Track.for_conference(Conference.current)).should be_empty
    end

    it "should assign session states" do
      get :index
      assigns(:states).should == Session.state_machine.states.map(&:name)
    end

    it "should filter sessions" do
      Session.expects(:with_state).with(:accepted).returns(Session)

      get :index, :session_filter => {:state => 'accepted'}
      assigns(:sessions).should == [@session]
    end

    it "should find sessions on organizer's tracks" do
      Session.expects(:for_tracks).with([@organizer.track.id]).returns(Session)

      get :index
      assigns(:sessions).should == [@session]
    end
  end
end
