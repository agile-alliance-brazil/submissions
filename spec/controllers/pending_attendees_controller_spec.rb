require 'spec_helper'

describe PendingAttendeesController do
  render_views
  
  it_should_require_login_for_actions :index, :update

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
  
  describe "PUT update" do
    before do
      @now = Time.zone.local(2011, 6, 6)
      Time.zone.stubs(:now).returns(@now)
      @attendee ||= Factory(:attendee)
    end
    
    it "update action should redirect to pending attendees" do
      @attendee.stubs(:valid?).returns(true)
      put :update, :id => @attendee.id
      response.should redirect_to(pending_attendees_path)
    end
    
    it "updates registration date when status is update" do
      put :update, :id => @attendee.id, :status => 'update'
      assigns(:attendee).registration_date.should == @now
    end
    
    it "marks attendee as paid when status is paid" do
      put :update, :id => @attendee.id, :status => 'paid'
      assigns(:attendee).should be_paid
    end
  end
end
