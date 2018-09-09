# frozen_string_literal: true

require 'spec_helper'

describe ReviewDecisionsController, type: :controller do
  render_views

  it_should_require_login_for_actions :new, :create, :edit, :update, :index

  before do
    conference = FactoryBot.create(:conference)
    Conference.stubs(:current).returns(conference)
    @session ||= FactoryBot.create(:session, conference: conference)
    @session.reviewing
    @organizer ||= FactoryBot.create(:organizer, track: @session.track, conference: @session.conference)
    sign_in @organizer.user
    disable_authorization
    # TODO: Remove need to create outcomes. This is a mess
    Outcome.find_by(title: 'outcomes.accept.title') || FactoryBot.create(:accepted_outcome)
    Outcome.find_by(title: 'outcomes.reject.title') || FactoryBot.create(:rejected_outcome)
  end

  it 'index action (JS) should render JSON' do
    FactoryBot.create(:session, track: @session.track, conference: @session.conference)
    FactoryBot.create(:rejected_decision, session: @session, organizer: @organizer.user)

    xhr :get, :index, format: :json
    expect(response.body).to eq({
      'required_decisions' => 2,
      'total_decisions' => 1,
      'total_accepted' => 0,
      'total_confirmed' => 0
    }.to_json)
  end

  it 'new action should render new template' do
    get :new, session_id: Session.first.id
    expect(response).to render_template(:new)
    expect(assigns(:review_decision).organizer).to eq(@organizer.user)
  end

  it 'create action should render new template when model is invalid' do
    post :create, session_id: @session.id, review_decision: { note_to_authors: 'bla' }
    expect(response).to render_template(:new)
  end

  it 'create action should redirect when model is valid' do
    post :create, session_id: @session.id, review_decision: { outcome_id: '1', note_to_authors: 'Super note' }
    expect(response).to redirect_to(organizer_sessions_url(@session.conference))
  end

  context 'existing review decision' do
    before do
      @decision ||= FactoryBot.create(:review_decision, session: @session, organizer: @organizer.user)
    end

    it 'edit action should render edit template' do
      get :edit, session_id: @session.id, id: @decision.id
      expect(response).to render_template(:edit)
      expect(assigns(:review_decision).organizer).to eq(@organizer.user)
    end

    it 'update action should render edit template when model is invalid' do
      patch :update, session_id: @session.id, id: @decision.id, review_decision: { outcome_id: nil }

      expect(response).to render_template(:edit)
    end

    it 'update action should redirect when model is valid' do
      patch :update, session_id: @session.id, id: @decision.id, review_decision: { outcome_id: '1', note_to_authors: 'Super note' }

      expect(response).to redirect_to(organizer_sessions_url(@session.conference))
    end
  end
end
