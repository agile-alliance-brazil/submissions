require 'spec/spec_helper'
 
describe UsersController do
  integrate_views
  
  it_should_require_logout_for_actions :new, :create
  
  before(:each) do
    Factory(:user)
  end

  it "index action should render index template for JS format" do
    get :index, :format => :js
    response.should render_template(:index)
  end
  
  it "index action should render index template for HTML format" do
    get :index
    response.should redirect_to(new_user_path)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :user => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    User.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(root_url)
  end

  it "create action should login new user" do
    UserSession.should_receive(:create).with(an_instance_of(User))
    post :create
  end
  
  it "show action should render show template" do
    get :show, :id => User.first
    response.should render_template(:show)
  end

end
