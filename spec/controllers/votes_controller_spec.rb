require 'spec/spec_helper'
 
describe VotesController do
  integrate_views

  it_should_require_login_for_actions :new, :create, :index

  before(:each) do
    @user = Factory(:user)
    activate_authlogic
    UserSession.create(@user)
  end

  it "index action should redirect to new" do
    get :index
    response.should redirect_to(new_vote_path)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "new action should search for previous vote for current user" do
    get :new
    assigns[:previous_vote].should be_nil
    vote = Factory(:vote, :user_id => @user.id)
    get :new
    assigns[:vote].should == vote
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :vote => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Vote.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(new_vote_url)
  end
  
  it "update action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    vote = Factory(:vote, :user_id => @user.id)
    post :update, :id => vote.id, :vote => { :logo_id => 89923982}
    response.should render_template(:new)
  end
  
  it "update action should redirect when model is valid" do
    Factory(:vote, :user_id => @user.id)
    post :update, :id => 1
    response.should redirect_to(new_vote_url)
  end
end
