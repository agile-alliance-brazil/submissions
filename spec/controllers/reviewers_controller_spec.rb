require 'spec/spec_helper'
 
describe ReviewersController do
  integrate_views

  it_should_require_login_for_actions :index, :new, :create, :update

  before(:each) do
    @user = Factory(:user)
    activate_authlogic    
    UserSession.create(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :reviewer => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    post :create, :reviewer => {:user_id => @user.id}
    response.should redirect_to(reviewers_path)
  end
  
  it "update action should render accept_reviewers/show template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    reviewer = Factory(:reviewer)
    put :update, :id => reviewer.id, :reviewer => {}
    response.should render_template('accept_reviewers/show')
  end

  it "update action should redirect when model is valid" do
    reviewer = Factory(:reviewer)
    reviewer.stubs(:valid?).returns(true)
    put :update, :id => reviewer.id
    response.should redirect_to(reviewer_sessions_path)
  end
  
  
  it "destroy action should redirect" do
    reviewer = Factory(:reviewer, :user_id => @user.id)
    delete :destroy, :id => reviewer.id
    response.should redirect_to(reviewers_path)
  end
end
