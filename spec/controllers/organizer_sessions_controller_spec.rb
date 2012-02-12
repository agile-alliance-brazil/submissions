# encoding: UTF-8
require 'spec_helper'

describe OrganizerSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @organizer = FactoryGirl.create(:organizer)
    sign_in @organizer.user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should find sessions on organizer's tracks" do
    Session.stubs(:for_user).returns(Session)
    Session.expects(:for_conference).at_least(1).with(@organizer.conference).returns(Session)
    Session.expects(:for_tracks).with([@organizer.track.id]).returns([])
    get :index
    assigns(:sessions).should == []
  end
end
