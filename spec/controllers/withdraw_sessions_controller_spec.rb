require 'spec/spec_helper'
 
describe WithdrawSessionsController do
  integrate_views

  it_should_require_login_for_actions :show, :update

  before(:each) do
    @user = Factory(:user)
    @session = Factory(:session, :author => @user)
    @session.reviewing
    Factory(:review_decision, :session => @session)
    @session.tentatively_accept
    Session.stubs(:find).returns(@session)
    activate_authlogic    
    UserSession.create(@user)
  end

  it "show action should render show template" do
    get :show, :session_id => @session.id
    response.should render_template(:show)
  end
  
  it "update action should render show template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, :session_id => @session.id, :session => {:author_agreement => false}
    response.should render_template(:show)
  end

  it "update action should redirect when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    put :update, :session_id => @session.id, :session => {}
    response.should redirect_to(user_my_sessions_path(@user))
  end
end
