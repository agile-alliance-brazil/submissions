require 'spec_helper'
 
describe ReviewerSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @conference = Factory(:conference)
    @user = Factory(:user)
    @reviewer = Factory(:reviewer, :user => @user, :conference => @conference)
    sign_in @user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should find sessions for reviewer" do
    Session.expects(:for_reviewer).with(@user, @conference).returns([])
    get :index
    assigns(:sessions).should == []
  end
end