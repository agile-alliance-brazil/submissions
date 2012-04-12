# encoding: UTF-8
require 'spec_helper'

describe OrganizerSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @organizer = FactoryGirl.create(:organizer)
    sign_in @organizer.user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "index action should find sessions on organizer's tracks" do
    session = FactoryGirl.create(:session, :conference => @organizer.conference, :track => @organizer.track)
    review_decision = FactoryGirl.create(:review_decision, :session => session, :organizer => @organizer.user)
    get :index
    assigns(:sessions).should == [session]
  end
end
