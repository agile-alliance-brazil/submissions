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
      Conference.stubs(:current).returns(Conference.find_by_year(2012))
      get :index
      assigns(:activities).should == Activity.all
    end
  end
end
