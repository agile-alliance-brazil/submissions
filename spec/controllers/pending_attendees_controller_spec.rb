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
      Time.zone.stubs(:now).returns(Time.zone.local(2011, 4, 25))
      get :index
      response.should render_template(:index)
    end
  end

  describe "PUT update" do
    before do
      @attendee ||= Factory(:attendee, :registration_date => Time.zone.local(2011, 4, 25))
    end

    it "update action should redirect to pending attendees" do
      @attendee.stubs(:valid?).returns(true)
      put :update, :id => @attendee.id
      response.should redirect_to(pending_attendees_path)
    end

    it "updates registration date when status is update" do
      Time.zone.stubs(:now).returns(Time.zone.local(2011, 4, 26))
      put :update, :id => @attendee.id, :status => 'update'
      assigns(:attendee).registration_date.should == Time.zone.local(2011, 4, 26)
    end

    it "marks attendee as paid when status is paid" do
      put :update, :id => @attendee.id, :status => 'paid'
      assigns(:attendee).should be_paid
    end
  end
end
