# frozen_string_literal: true

require 'spec_helper'

describe OrganizersController, type: :controller do
  before(:each) do
    @user ||= FactoryGirl.create(:user)
    # TODO: Improve conference usage
    @conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)
    sign_in @user
    disable_authorization
  end

  describe 'with view rendering', render_views: true do
    render_views

    it 'index should work' do
      get :index
    end

    it 'new should work' do
      get :new
    end
  end

  it_should_require_login_for_actions :index, :new, :create, :edit, :update, :destroy

  it 'new action should only load conference tracks' do
    get :new
    expect((assigns(:tracks) - Track.for_conference(@conference))).to be_empty
  end

  it 'create action should render new template when model is invalid' do
    post :create, organizer: { track_id: nil }
    expect(response).to render_template(:new)
  end

  it 'create action should redirect when model is valid' do
    user = FactoryGirl.create(:user)
    track = FactoryGirl.create(:track, conference: @conference)
    post :create, organizer: { user_username: user.username, track_id: track.id, conference_id: track.conference_id }
    expect(response).to redirect_to(organizers_path(@conference))
  end

  it 'edit action should only load conference tracks' do
    organizer = FactoryGirl.create(:organizer, user_id: @user.id, conference: @conference)
    get :edit, id: organizer.id
    expect((assigns(:tracks) - Track.for_conference(@conference))).to be_empty
  end

  it 'update action should render edit template when model is invalid' do
    organizer = FactoryGirl.create(:organizer, user_id: @user.id, conference: @conference)
    post :update, id: organizer.id, organizer: { track_id: nil }
    expect(response).to render_template(:edit)
  end

  it 'update action should redirect when model is valid' do
    organizer = FactoryGirl.create(:organizer, user_id: @user.id, conference: @conference)
    post :update, id: organizer.id, organizer: {
      track_id: @conference.tracks.first.id,
      user_username: @user.username
    }
    expect(response).to redirect_to(organizers_path(@conference))
  end

  it 'destroy action should redirect' do
    organizer = FactoryGirl.create(:organizer, user_id: @user.id, conference: @conference)
    delete :destroy, id: organizer.id
    expect(response).to redirect_to(organizers_path(@conference))
  end
end
