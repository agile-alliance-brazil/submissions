require 'spec_helper'
 
describe OrganizerSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @user = Factory(:user)
    @organizer = Factory(:organizer, :user => @user)
    activate_authlogic
    UserSession.create(@user)
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should find sessions on organizer's tracks" do
    Session.expects(:for_tracks).with([@organizer.track.id]).returns([])
    get :index
    assigns(:sessions).should == []
  end
end