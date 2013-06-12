# encoding: UTF-8
require 'spec_helper'

describe AcceptedSessionsController, :render_views => true do
  render_views

  it "index should work" do
    FactoryGirl.create_list(:session, 3)
    get :index
  end
end

describe AcceptedSessionsController do
  describe "#index" do
    it "should fetch all activities" do
      conference = Conference.find_by_year(2012)
      Conference.stubs(:current).returns(conference)
      get :index
      assigns(:activities).should == Activity.for_conference(conference)
    end
  end
end
