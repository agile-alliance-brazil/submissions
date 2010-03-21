require 'spec/spec_helper'
 
describe OrganizerSessionsController do
  integrate_views

  it_should_require_login_for_actions :index

  before(:each) do
    @user = Factory(:user)
    activate_authlogic
    UserSession.create(@user)
  end

  it "index action should render index template" do
    Factory(:organizer, :user => @user)
    get :index
    response.should render_template(:index)
  end
  
  it "index action should find sessions on organizer's tracks" do
    organizer = Factory(:organizer, :user => @user)
    Session.expects(:for_tracks).with([organizer.track.id]).returns([])
    get :index
    assigns[:sessions].should == []
  end
end
