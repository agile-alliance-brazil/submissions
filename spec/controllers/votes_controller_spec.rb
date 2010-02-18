require File.dirname(__FILE__) + '/../spec_helper'
 
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
    assigns[:previous_vote].should == vote
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

end
