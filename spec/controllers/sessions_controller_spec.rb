require 'spec/spec_helper'
 
describe SessionsController do
  integrate_views

  it_should_require_login_for_actions :index, :show, :new, :create

  before(:each) do
    session = Factory(:session)
    activate_authlogic
    UserSession.create(session.author)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Session.first
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
    post :create, :session => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(session_url(assigns[:session]))
  end
    
end
