# encoding: UTF-8
require 'spec_helper'
 
describe ReviewDecisionsController do
  render_views

  it_should_require_login_for_actions :new, :create, :edit, :update, :index

  before(:each) do
    @session ||= FactoryGirl.create(:session)
    @organizer ||= FactoryGirl.create(:organizer, :track => @session.track, :conference => @session.conference)
    sign_in @organizer.user
    disable_authorization
  end

  it "index action (JS) should render JSON" do
    FactoryGirl.create(:session, :track => @session.track, :conference => @session.conference)
    FactoryGirl.create(:review_decision, :session => @session, :organizer => @organizer.user)

    get :index, :format => 'js'
    response.body.should == {
      'required_decisions' => 2,
      'total_decisions' => 1,
      'total_accepted' => 0,
      'total_confirmed' => 0
    }.to_json
  end
  
  it "new action should render new template" do
    get :new, :session_id => Session.first
    response.should render_template(:new)
    assigns(:review_decision).organizer.should == @organizer.user
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :review_decision => {}, :session_id => Session.first
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    ReviewDecision.any_instance.stubs(:valid?).returns(true)
    post :create, :session_id => Session.first
    response.should redirect_to(organizer_sessions_url(Conference.current))
  end
  
  context "existing review decision" do
    before(:each) do
      @decision ||= FactoryGirl.create(:review_decision, :session => @session, :organizer => @organizer.user)
    end
    
    it "edit action should render edit template" do
      get :edit, :session_id => @session.id, :id => @decision.id
      response.should render_template(:edit)
      assigns(:review_decision).organizer.should == @organizer.user
    end
  
    it "update action should render edit template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :update, :review_decision => {:note_to_authors => nil}, :session_id => @session.id, :id => @decision.id
      response.should render_template(:edit)
    end
  
    it "update action should redirect when model is valid" do
      ReviewDecision.any_instance.stubs(:valid?).returns(true)
      post :update, :session_id => @session.id, :id => @decision.id
      response.should redirect_to(organizer_sessions_url(Conference.current))
    end
  end
end
