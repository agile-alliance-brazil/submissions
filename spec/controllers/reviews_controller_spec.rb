require 'spec/spec_helper'
 
describe ReviewsController do
  integrate_views

  it_should_require_login_for_actions :index, :show, :new, :create

  before(:each) do
    @review = Factory(:review)
    activate_authlogic
    UserSession.create(@review.reviewer.user)
  end
  
  it "show action should render show template" do
    get :show, :id => Review.first
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :review => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Review.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(review_url(assigns[:review]))
  end
end
