require 'spec_helper'

describe AttendeeStatusesController do
  render_views
  
  before(:each) do
    @conference ||= Factory(:conference)
  end
  
  describe "GET show" do
    it "should render show template" do
      attendee = Factory(:attendee)
      get :show, :id => attendee.uri_token
      response.should render_template(:show)
      assigns(:attendee).should == attendee
    end
  end
end