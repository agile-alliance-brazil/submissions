# encoding: UTF-8
require 'spec_helper'

describe RegisteredAttendeesController do
  render_views

  it_should_require_login_for_actions :index, :show, :update

  before(:each) do
    @conference ||= FactoryGirl.create(:conference)
    @user ||= FactoryGirl.create(:user)
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
      @attendee ||= FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 4, 25))
    end

    it "should render show template" do
      get :show, :id => @attendee.id
      response.should render_template(:show)
    end
  end

  describe "PUT update" do
    before do
      @attendee ||= FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 4, 25))
    end

    it "update action should render show template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      put :update, :id => @attendee.id, :attendee => {:payment_agreement => false}
      response.should render_template(:show)
    end

    it "update action should redirect when model is valid" do
      @attendee.stubs(:valid?).returns(true)
      put :update, :id => @attendee.id, :attendee => {}
      response.should redirect_to(registered_attendees_path)
    end
  end
end
