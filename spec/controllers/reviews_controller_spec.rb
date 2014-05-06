# encoding: UTF-8
require 'spec_helper'

describe ReviewsController do
  before(:each) do
    @early_review ||= FactoryGirl.create(:early_review)
    FactoryGirl.create(:reviewer, user: @early_review.reviewer)
    @final_review ||= FactoryGirl.create(:final_review, :reviewer => @early_review.reviewer)

    sign_in @early_review.reviewer
    disable_authorization

    @conference = Conference.current
    Conference.stubs(:current).returns(@conference)
    @conference.stubs(:in_early_review_phase?).returns(false)
  end

  describe "with view rendering", :render_views => true do
    render_views

    it "index early reviews for organizer should work" do
      get :organizer, :session_id => Session.first, :type => 'early'
    end

    it "index final reviews for organizer should work" do
      get :organizer, :session_id => Session.first
    end

    it "index early reviews for author should work" do
      get :index, :session_id => Session.first, :type => 'early'
    end

    it "index final reviews for author should work" do
      get :index, :session_id => Session.first
    end

    it "show should work for early review" do
      get :show, :id => @early_review.id, :session_id => @early_review.session
    end

    it "show should work for final review" do
      get :show, :id => @final_review.id, :session_id => @final_review.session
    end

    it "new should work for early review" do
      @conference.expects(:in_early_review_phase?).returns(true)
      get :new, :session_id => Session.first
    end

    it "show should work for final review" do
      @conference.expects(:in_early_review_phase?).returns(false)
      get :new, :session_id => Session.first
    end
  end

  it_should_require_login_for_actions :index, :show, :new, :create

  it "new action should set reviewer" do
    get :new, :session_id => Session.first
    assigns(:review).reviewer.should == @final_review.reviewer
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :review => {}, :session_id => Session.first
    response.should render_template(:new)
  end

  it "create action should redirect when final review is valid" do
    @conference.expects(:in_early_review_phase?).returns(false)
    FinalReview.any_instance.expects(:valid?).returns(true)
    post :create, :session_id => Session.first
    response.should redirect_to(session_review_path(@conference, assigns(:session), assigns(:review)))
  end

  it "create action should redirect when early review is valid" do
    @conference.stubs(:in_early_review_phase?).returns(true)
    EarlyReview.any_instance.expects(:valid?).returns(true)
    post :create, :session_id => Session.first
    response.should redirect_to(session_review_path(@conference, assigns(:session), assigns(:review)))
  end
end
