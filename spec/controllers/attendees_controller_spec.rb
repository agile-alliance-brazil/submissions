require 'spec_helper'

describe AttendeesController do
  render_views

  before(:each) do
    @conference = Factory(:conference)
  end
  
  describe "GET index" do
    it "should redirect to new attendee form" do
      get :index
      response.should redirect_to(new_attendee_path)
    end
  end
  
  describe "GET new" do
    it "should render new template" do
      get :new
      response.should render_template(:new)
    end
    
    it "should assign current conference to attendee registration" do
      get :new
      assigns(:attendee).conference.should == @conference
    end
  end
  
  describe "POST create" do
    it "create action should render new template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :create, :attendee => {}
      response.should render_template(:new)
    end

    it "create action should redirect when model is valid" do
      Attendee.any_instance.stubs(:valid?).returns(true)
      post :create
      response.should redirect_to(root_path)
    end
    
    it "should send pending registration e-mail" do
      email = stub(:deliver => true)
      EmailNotifications.expects(:registration_pending).returns(email)
      Attendee.any_instance.stubs(:valid?).returns(true)
      post :create
    end
  end
end
