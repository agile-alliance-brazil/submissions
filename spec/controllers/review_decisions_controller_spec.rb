# encoding: UTF-8
require 'spec_helper'
 
describe ReviewDecisionsController, type: :controller do
  render_views

  it_should_require_login_for_actions :new, :create, :edit, :update, :index

  before(:each) do
    conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(conference)
    @session ||= FactoryGirl.create(:session, conference: conference)
    @session.reviewing
    @organizer ||= FactoryGirl.create(:organizer, track: @session.track, conference: @session.conference)
    sign_in @organizer.user
    disable_authorization
    # TODO: Remove need to create outcomes. This is a mess
    Outcome.find_by_title('outcomes.accept.title') || FactoryGirl.create(:accepted_outcome)
    Outcome.find_by_title('outcomes.reject.title') || FactoryGirl.create(:rejected_outcome)
  end

  it "index action (JS) should render JSON" do
    FactoryGirl.create(:session, track: @session.track, conference: @session.conference)
    FactoryGirl.create(:rejected_decision, session: @session, organizer: @organizer.user)

    xhr :get, :index, format: :js
    expect(response.body).to eq({
      'required_decisions' => 2,
      'total_decisions' => 1,
      'total_accepted' => 0,
      'total_confirmed' => 0
    }.to_json)
  end
  
  it "new action should render new template" do
    get :new, session_id: Session.first
    expect(response).to render_template(:new)
    expect(assigns(:review_decision).organizer).to eq(@organizer.user)
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, review_decision: {}, session_id: FactoryGirl.create(:session).id
    expect(response).to render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    ReviewDecision.any_instance.stubs(:valid?).returns(true)
    post :create, session_id: FactoryGirl.create(:session).id
    expect(response).to redirect_to(organizer_sessions_url(@session.conference))
  end
  
  context "existing review decision" do
    before(:each) do
      @decision ||= FactoryGirl.create(:review_decision, session: @session, organizer: @organizer.user)
    end
    
    it "edit action should render edit template" do
      get :edit, session_id: @session.id, id: @decision.id
      expect(response).to render_template(:edit)
      expect(assigns(:review_decision).organizer).to eq(@organizer.user)
    end
  
    it "update action should render edit template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :update, review_decision: {note_to_authors: nil}, session_id: @session.id, id: @decision.id
      expect(response).to render_template(:edit)
    end
  
    it "update action should redirect when model is valid" do
      ReviewDecision.any_instance.stubs(:valid?).returns(true)
      post :update, session_id: @session.id, id: @decision.id
      expect(response).to redirect_to(organizer_sessions_url(@session.conference))
    end
  end
end
