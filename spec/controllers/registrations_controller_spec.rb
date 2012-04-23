# encoding: UTF-8
require 'spec_helper'

describe RegistrationsController do
  render_views
  it_should_behave_like_a_devise_controller

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    EmailNotifications.stubs(:send_welcome)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "new action should build user with default locale" do
    get :new, :locale => 'en'
    assigns(:user).default_locale.to_sym.should == :en
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
    User.any_instance.stubs(:valid?).returns(true)
#    UserSession.expects(:create).with(instance_of(User))
    post :create
  end

  it "create action should send welcome e-mail" do
    EmailNotifications.expects(:send_welcome)
    User.any_instance.stubs(:valid?).returns(true)
    post :create
  end

  context "logged in" do
    before(:each) do
      sign_in @user
      disable_authorization
    end

    it "edit action should render edit template" do
      get :edit
      response.should render_template(:edit)
    end

    it "edit action should set default locale regardless of params" do
      get :edit, :locale => 'en'
      assigns(:user).default_locale.to_sym.should == :pt
    end

    it "update action should render edit template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      put :update, :user => {:username => nil}
      response.should render_template(:edit)
    end

    it "update action should redirect when model is valid" do
      put :update, :user => {:current_password => 'secret'}
      response.should redirect_to(user_path(assigns(:user)))
    end
  end

end
