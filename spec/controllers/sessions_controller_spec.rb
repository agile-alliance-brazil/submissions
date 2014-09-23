# encoding: UTF-8
require 'spec_helper'

describe SessionsController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :show, :new, :create, :edit, :update

  before(:each) do
    @session ||= FactoryGirl.create(:session)
    @conference ||= @session.conference
    sign_in @session.author
    disable_authorization
    EmailNotifications.stubs(:session_submitted).returns(stub(deliver: true))
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "index action shouldn't display cancelled sessions" do
    @session.cancel
    get :index
    expect(assigns(:sessions)).to be_empty
  end

  it "show action should render show template" do
    get :show, id: Session.first
    expect(response).to render_template(:show)
    expect(assigns(:comment).user).to eq(@session.author)
    expect(assigns(:comment).commentable_id).to eq(Session.first.id)
  end

  it "show action should display flash news if session from previous conference" do
    old_conference = FactoryGirl.create(:conference, year: 1)
    old_session = FactoryGirl.create(:session,
      session_type: FactoryGirl.create(:session_type, conference: old_conference),
      audience_level: FactoryGirl.create(:audience_level, conference: old_conference),
      track: FactoryGirl.create(:track, conference: old_conference),
      conference: old_conference
    )
    
    get :show, id: old_session.id

    message = I18n.t('flash.news.session_different_conference',
      conference_name: old_conference.name,
      current_conference_name: @conference.name,
      locale: @session.author.default_locale)
    expect(flash[:news]).to eq(message)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "new action should only assign tracks for current conference" do
    get :new
    non_current_tracks = (assigns(:tracks) - @conference.tracks)
    expect(non_current_tracks).to be_empty
  end

  it "new action should only assign audience levels for current conference" do
    get :new
    non_current_levels = (assigns(:audience_levels) - @conference.audience_levels)
    expect(non_current_levels).to be_empty
  end

  it "new action should only assign session types for current conference" do
    get :new
    non_current_session_types = (assigns(:session_types) - @conference.session_types)
    expect(non_current_session_types).to be_empty
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, session: {}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    post :create
    expect(response).to redirect_to(session_url(@conference, assigns(:session)))
  end

  it "create action should send an email when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    EmailNotifications.expects(:session_submitted).returns(mock(deliver: true))
    post :create
  end

  it "edit action should render edit template" do
    get :edit, id: Session.first
    expect(response).to render_template(:edit)
  end

  it "edit action should only assign tracks for current conference" do
    get :edit, id: Session.first
    expect((assigns(:tracks) - @conference.tracks)).to be_empty
  end

  it "edit action should only assign audience levels for current conference" do
    get :edit, id: Session.first
    expect((assigns(:audience_levels) - @conference.audience_levels)).to be_empty
  end

  it "edit action should only assign session types for current conference" do
    get :edit, id: Session.first
    expect((assigns(:session_types) - @conference.session_types)).to be_empty
  end

  it "update action should render edit template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, id: Session.first, session: {title: nil}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    put :update, id: Session.first
    expect(response).to redirect_to(session_path(@conference, assigns(:session)))
  end

  it "cancel action should cancel and redirect to organizer sessions" do
    delete :cancel, id: Session.first
    expect(response).to redirect_to(organizer_sessions_path(@conference))
  end

  it "cancel action should redirect to organizer sessions with error" do
    session = FactoryGirl.create(:session, track: @session.track)
    session.cancel
    delete :cancel, id: session
    expect(response).to redirect_to(organizer_sessions_path(@conference))
    expect(flash[:error]).to eq(I18n.t('flash.session.cancel.failure', locale: @session.author.default_locale))
  end
end
