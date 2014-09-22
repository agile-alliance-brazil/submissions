# encoding: UTF-8
require 'spec_helper'

describe ReviewersController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :new, :create

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    @conference ||= FactoryGirl.create(:conference)
    sign_in @user
    disable_authorization
    EmailNotifications.stubs(:reviewer_invitation).returns(stub(deliver: true))
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "index action should assign tracks for current conference" do
    get :index
    expect((assigns(:tracks) - Track.for_conference(@conference))).to be_empty
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, reviewer: {}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    post :create, reviewer: {user_id: @user.id, conference_id: @conference.id}
    expect(response).to redirect_to(reviewers_path(@conference))
  end

  it "destroy action should redirect" do
    reviewer = FactoryGirl.create(:reviewer, user_id: @user.id)
    delete :destroy, id: reviewer.id
    expect(response).to redirect_to(reviewers_path(@conference))
  end
end
