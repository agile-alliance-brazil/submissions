require 'spec_helper'

describe RegistrationGroupsController do
  render_views

  before(:each) do
    @conference = Factory(:conference)
  end
  
  describe "GET index" do
    it "should redirect to new registration group form" do
      get :index
      response.should redirect_to(new_registration_group_path)
    end
  end
  
  describe "GET new" do
    it "should render new template" do
      get :new
      response.should render_template(:new)
    end
    
    it "should display news message" do
      get :new
      flash[:news].should_not be_nil
    end
  end
  
  describe "POST create" do
    it "create action should render new template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :create, :registration_group => {}
      response.should render_template(:new)
    end

    it "create action should redirect when model is valid" do
      RegistrationGroup.any_instance.stubs(:valid?).returns(true)
      post :create
      response.should redirect_to(new_registration_group_attendee_path(assigns(:registration_group)))
    end    
  end
end
