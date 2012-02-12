# encoding: UTF-8
require 'spec_helper'
 
describe ReviewerSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    @reviewer ||= FactoryGirl.create(:reviewer)
    sign_in @reviewer.user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should find sessions for reviewer" do
    Session.expects(:for_reviewer).with(@reviewer.user, @reviewer.conference).returns([])
    get :index
    assigns(:sessions).should == []
  end
end
