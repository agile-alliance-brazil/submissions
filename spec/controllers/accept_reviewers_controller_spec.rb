require 'spec/spec_helper'
 
describe AcceptReviewersController do
  integrate_views

  it_should_require_login_for_actions :show, :update

  before(:each) do
    @user = Factory(:user)
    @reviewer = Factory(:reviewer, :user => @user)
    Reviewer.stubs(:find).returns(@reviewer)
    activate_authlogic    
    UserSession.create(@user)
  end

  it "show action should render show template" do
    get :show, :reviewer_id => @reviewer.id
    response.should render_template(:show)
  end
  
  it "update action should render show template when transition is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    @reviewer.expects(:accept).returns(false)
    put :update, :reviewer_id => @reviewer.id
    response.should render_template(:show)
  end
  
  it "update action should redirect when transition is valid" do
    put :update, :reviewer_id => @reviewer.id
    response.should redirect_to(root_path)
  end
end
