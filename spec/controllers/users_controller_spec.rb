require 'spec/spec_helper'
 
describe UsersController do
  integrate_views
  
  it_should_require_logout_for_actions :new, :create
  it_should_require_login_for_actions :edit, :update
  
  before(:each) do
    @user = Factory(:user)
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

  it "new action should build user with default locale" do
    get :new, :locale => 'en'
    assigns[:user].default_locale.should == 'en'
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
    UserSession.expects(:create).with(instance_of(User))
    post :create
  end
  
  it "show action should render show template" do
    get :show, :id => User.first
    response.should render_template(:show)
  end
  
  context "logged in" do
    before(:each) do
      activate_authlogic
      UserSession.create(@user)
    end
    
    it "edit action should render edit template" do
      get :edit, :id => @user
      response.should render_template(:edit)
    end

    it "edit action should set default locale regardless of params" do
      get :edit, :id => @user, :locale => 'en'
      assigns[:user].default_locale.should == 'pt'
    end
  
    it "update action should render edit template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      put :update, :id => @user, :user => {:username => nil}
      response.should render_template(:edit)
    end

    it "update action should redirect when model is valid" do
      put :update, :id => @user
      response.should redirect_to(user_path(assigns[:user]))
    end
  end  

end
