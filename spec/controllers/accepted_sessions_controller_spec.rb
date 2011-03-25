require 'spec_helper'
 
describe AcceptedSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @conference = Factory(:conference)
    user = Factory(:user)
    sign_in user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "index action should find accepted sessions" do
    Session.expects(:for_conference).with(@conference).returns(Session)
    Session.expects(:with_state).with(:accepted).returns([])
    get :index
    assigns(:sessions).should == []
  end

end