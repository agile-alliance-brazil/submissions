# encoding: utf-8
require 'spec_helper'
 
describe SessionsController do
  render_views

  it_should_require_login_for_actions :index, :show, :new, :create, :edit, :update

  before(:each) do
    @session = Factory(:session)
    activate_authlogic
    UserSession.create(@session.author)
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Session.first
    response.should render_template(:show)
    assigns(:comment).user.should == @session.author
    assigns(:comment).commentable_id.should == Session.first.id
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
    response.should redirect_to(session_url(assigns(:session)))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Session.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, :id => Session.first, :session => {:title => nil}
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    put :update, :id => Session.first
    response.should redirect_to(session_path(assigns(:session)))
  end

  it "cancel action should cancel and redirect to organizer sessions" do
    delete :cancel, :id => Session.first
    response.should redirect_to(organizer_sessions_path)
  end
  
  it "cancel action should redirect to organizer sessions with error" do
    session = Factory(:session)
    session.cancel
    delete :cancel, :id => session
    response.should redirect_to(organizer_sessions_path)
    flash[:error].should == "Sessão já está cancelada."
  end
end
