# encoding: UTF-8
require 'spec_helper'

describe AttendeeStatusesController do
  render_views

  describe "GET show" do
    it "should render show template" do
      attendee = FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 4, 25))
      get :show, :id => attendee.uri_token
      response.should render_template(:show)
      assigns(:attendee).should == attendee
    end
  end
end
