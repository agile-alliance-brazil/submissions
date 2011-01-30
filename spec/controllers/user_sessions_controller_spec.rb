require 'spec/spec_helper'
 
describe UserSessionsController do
  fixtures :users
  integrate_views
  
  it_should_require_login_for_actions :destroy
  it_should_require_logout_for_actions :create
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when authentication is invalid" do
    post :create, :user_session => { :username => "foo", :password => "badpassword" }
    response.should render_template(:new)
    UserSession.find.should be_nil
  end
  
  it "create action should redirect when authentication is valid with user's default locale" do
    post :create, :user_session => { :username => "foo", :password => "secret" }
    response.should redirect_to(root_url(:locale => 'en'))
    UserSession.find.user.should == users(:foo)
  end
end
