# encoding: UTF-8
require 'spec_helper'

describe RegistrationGroupStatusesController do
  render_views
  
  describe "GET show" do
    it "should render show template" do
      registration_group = FactoryGirl.create(:registration_group)
      get :show, :id => registration_group.uri_token
      response.should render_template(:show)
      assigns(:registration_group).should == registration_group
    end
  end
  
end
