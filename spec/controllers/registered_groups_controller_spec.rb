# encoding: UTF-8
require 'spec_helper'

describe RegisteredGroupsController do
  render_views
  
  it_should_require_login_for_actions :index#, :show, :update

  before(:each) do
    @conference = Factory(:conference)
    @user ||= Factory(:user)
    sign_in @user
    disable_authorization
  end
  
  describe "GET index" do
    it "should render index template" do
      get :index
      response.should render_template(:index)
    end
  end
  
  describe "GET show" do
    before do
      @registration_group ||= Factory(:registration_group)
    end
    
    it "should render show template" do
      get :show, :id => @registration_group.id
      response.should render_template(:show)
    end
  end
  
  describe "PUT update" do
    before do
      @registration_group ||= Factory(:registration_group)
    end
    
    it "update action should render show template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      put :update, :id => @registration_group.id, :registration_group => {:payment_agreement => false}
      response.should render_template(:show)
    end
  
    it "update action should redirect when model is valid" do
      @registration_group.stubs(:valid?).returns(true)
      put :update, :id => @registration_group.id
      response.should redirect_to(registered_groups_path)
    end
  end
end
