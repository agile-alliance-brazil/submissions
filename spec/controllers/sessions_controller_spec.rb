# encoding: UTF-8
require 'spec_helper'

describe SessionsController do
  render_views

  it_should_require_login_for_actions :index, :show, :new, :create, :edit, :update

  before(:each) do
    @session ||= FactoryGirl.create(:session)
    sign_in @session.author
    disable_authorization
    EmailNotifications.stubs(:send_session_submitted)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "index action shouldn't display cancelled sessions" do
    @session.cancel
    get :index
    assigns(:sessions).should be_empty
  end

  it "show action should render show template" do
    get :show, :id => Session.first
    response.should render_template(:show)
    assigns(:comment).user.should == @session.author
    assigns(:comment).commentable_id.should == Session.first.id
  end

  it "show action should display flash news if session from previous conference" do
    old_session = FactoryGirl.create(:session,
      :session_type => SessionType.first,
      :audience_level => AudienceLevel.first,
      :track => Track.first,
      :conference => Conference.first
    )
    FactoryGirl.create(:session)
    get :show, :id => old_session.id
    flash[:news].should == "Você está acessando uma proposta da #{old_session.conference.name}. Veja as <a href='/sessions?locale=pt'>sessões</a> da #{Conference.current.name}."
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "new action should only assign tracks for current conference" do
    get :new
    (assigns(:tracks) - Conference.current.tracks).should be_empty
  end

  it "new action should only assign audience levels for current conference" do
    get :new
    (assigns(:audience_levels) - Conference.current.audience_levels).should be_empty
  end

  it "new action should only assign session types for current conference" do
    get :new
    (assigns(:session_types) - Conference.current.session_types).should be_empty
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :session => {}
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(session_url(Conference.current, assigns(:session)))
  end

  it "create action should send an email when model is valid" do
    Session.any_instance.stubs(:valid?).returns(true)
    EmailNotifications.expects(:send_session_submitted)
    post :create
  end

  it "edit action should render edit template" do
    get :edit, :id => Session.first
    response.should render_template(:edit)
  end

  it "edit action should only assign tracks for current conference" do
    get :edit, :id => Session.first
    (assigns(:tracks) - Conference.current.tracks).should be_empty
  end

  it "edit action should only assign audience levels for current conference" do
    get :edit, :id => Session.first
    (assigns(:audience_levels) - Conference.current.audience_levels).should be_empty
  end

  it "edit action should only assign session types for current conference" do
    get :edit, :id => Session.first
    (assigns(:session_types) - Conference.current.session_types).should be_empty
  end

  it "update action should render edit template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, :id => Session.first, :session => {:title => nil}
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    put :update, :id => Session.first
    response.should redirect_to(session_path(Conference.current, assigns(:session)))
  end

  it "cancel action should cancel and redirect to organizer sessions" do
    delete :cancel, :id => Session.first
    response.should redirect_to(organizer_sessions_path(Conference.current))
  end

  it "cancel action should redirect to organizer sessions with error" do
    session = FactoryGirl.create(:session, :track => @session.track)
    session.cancel
    delete :cancel, :id => session
    response.should redirect_to(organizer_sessions_path(Conference.current))
    flash[:error].should == "Sessão já está cancelada."
  end
end
