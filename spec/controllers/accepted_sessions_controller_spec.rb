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
    it "should only display accepted sessions" do
      session = FactoryGirl.create(:session)
      accepted_session = FactoryGirl.create(:session, :state => :accepted)

      get :index
      assigns(:sessions).should == [accepted_session]
    end
  end
end
