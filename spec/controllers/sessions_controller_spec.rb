# encoding: UTF-8
require 'spec_helper'

describe SessionsController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :show, :new, :create, :edit, :update

  let(:author) { FactoryGirl.create(:author) }
  let(:conference) { FactoryGirl.create(:conference) }
  let(:audience_level) { FactoryGirl.create(:audience_level, conference: conference) }
  let(:session_type) { FactoryGirl.create(:session_type, conference: conference) }
  let(:track) { FactoryGirl.create(:track, conference: conference) }
  let(:session) { FactoryGirl.create(:session, conference: conference, author: author)}
  let(:valid_params) do
    {
      title: 'Testing',
      summary: 'Testing a summary',
      description: 'Testing a description that is long.' * 50,
      mechanics: 'Testing medium mechanics' * 10,
      benefits: 'Testing medium benefits' * 10,
      target_audience: 'Everybody!',
      prerequisites: 'None!',
      audience_level_id: audience_level.id,
      track_id: track.id,
      session_type_id: session_type.id,
      duration_mins: session_type.valid_durations.first.to_s,
      experience: 'A lot!',
      keyword_list: 'tag,another',
      language: 'pt'
    }
  end
  before(:each) do
    # Need session types to suggest durations in the form
    @session_types = [session_type]

    sign_in author
    disable_authorization
    EmailNotifications.stubs(:session_submitted).returns(stub(deliver: true))
  end

  context 'index action' do
    it 'index action should render index template' do
      get :index, year: conference.year

      expect(response).to render_template(:index)
    end

    it 'index action should not display cancelled sessions' do
      session.cancel

      get :index, year: conference.year

      expect(assigns(:sessions)).to be_empty
    end
  end

  context 'show action' do
    it 'should render show template with comment' do
      get :show, year: conference.year, id: session.id

      expect(response).to render_template(:show)
      expect(assigns(:comment).user).to eq(author)
      expect(assigns(:comment).commentable_id).to eq(session.id)
    end

    it 'should display flash news if session from previous conference' do
      old_conference = FactoryGirl.create(:conference, year: 1)
      old_session = FactoryGirl.create(:session,
        session_type: FactoryGirl.create(:session_type, conference: old_conference),
        audience_level: FactoryGirl.create(:audience_level, conference: old_conference),
        track: FactoryGirl.create(:track, conference: old_conference),
        conference: old_conference
      )

      get :show, year: conference.year, id: old_session.id

      message = I18n.t('flash.news.session_different_conference',
        conference_name: old_conference.name,
        current_conference_name: conference.name,
        locale: author.default_locale)
      expect(flash[:news]).to eq(message)
    end
  end

  context 'new action' do
    before do
      @tracks = [track]
      @audience_levels = [audience_level]
    end
    it 'should render new template' do
      get :new, year: conference.year

      expect(response).to render_template(:new)
    end

    it 'should only assign tracks for current conference' do
      get :new, year: conference.year

      expect(assigns(:tracks)).to eq(@tracks)
    end

    it 'should only assign audience levels for current conference' do
      get :new, year: conference.year

      expect(assigns(:audience_levels)).to eq(@audience_levels)
    end

    it 'should only assign session types for current conference' do
      get :new, year: conference.year

      expect(assigns(:session_types)).to eq(@session_types)
    end
  end

  context 'create action' do
    it 'create action should render new template when model is invalid' do
      post :create, year: conference.year, session: {title: 'Test'}

      expect(response).to render_template(:new)
    end

    it 'create action should redirect when model is valid' do
      post :create, year: conference.year, session: valid_params

      expect(response).to redirect_to(session_url(conference, assigns(:session)))
    end

    it 'create action should send an email when model is valid' do
      EmailNotifications.expects(:session_submitted).returns(mock(deliver: true))

      post :create, year: conference.year, session: valid_params
    end
  end

  context 'edit action' do
    it 'edit action should render edit template' do
      get :edit, year: conference.year, id: session.id

      expect(response).to render_template(:edit)
    end

    it 'edit action should only assign tracks for current conference' do
      get :edit, year: conference.year, id: session.id

      expect(assigns(:tracks) - conference.tracks).to be_empty
    end

    it 'edit action should only assign audience levels for current conference' do
      get :edit, year: conference.year, id: session.id

      expect(assigns(:audience_levels) - conference.audience_levels).to be_empty
    end

    it 'edit action should only assign session types for current conference' do
      get :edit, year: conference.year, id: session.id

      expect(assigns(:session_types) - conference.session_types).to be_empty
    end
  end

  context 'update action' do
    it 'should render edit template when model is invalid' do
      patch :update, year: conference.year, id: session.id, session: {title: nil}

      expect(response).to render_template(:edit)
    end

    it 'should redirect when model is valid' do
      patch :update, year: conference.year, id: session.id, session: valid_params

      expect(response).to redirect_to(session_path(conference, assigns(:session)))
    end
  end

  context 'cancel action' do
    it 'should cancel and redirect to organizer sessions' do
      delete :cancel, year: conference.year, id: session.id

      expect(response).to redirect_to(organizer_sessions_path(conference))
    end

    it 'should redirect to organizer sessions with error' do
      session.cancel

      delete :cancel, year: conference.year, id: session.id

      expect(response).to redirect_to(organizer_sessions_path(conference))

      error_message = I18n.t('flash.session.cancel.failure',
        locale: author.default_locale)
      expect(flash[:error]).to eq(error_message)
    end
  end
end
