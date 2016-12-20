# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe AcceptReviewersController, type: :controller do
  let(:conference) { FactoryGirl.create(:conference) }
  let(:reviewer) { FactoryGirl.create(:reviewer, conference: conference) }
  let(:track) { FactoryGirl.create(:track, conference: conference) }
  let(:audience_level) { FactoryGirl.create(:audience_level, conference: conference) }
  before(:each) do
    @track = track
    @audience_level = audience_level
    sign_in reviewer.user
    disable_authorization
  end

  describe 'with view rendering', render_views: true do
    render_views

    it 'show pt should work' do
      get :show, year: conference.year, reviewer_id: reviewer.id, locale: :'pt-BR'
    end

    it 'show en should work' do
      get :show, year: conference.year, reviewer_id: reviewer.id, locale: :en
    end
  end

  it_should_require_login_for_actions :show, :update

  it 'show action should render show template' do
    get :show, year: conference.year, reviewer_id: reviewer.id

    expect(response).to render_template(:show)
  end

  it 'show action should populate preferences for each track when empty' do
    get :show, year: conference.year, reviewer_id: reviewer.id

    expect(assigns(:reviewer).preferences.size).to eq(conference.tracks.count)
  end

  it 'show action should keep preferences when already present' do
    reviewer.preferences.create(track_id: @track.id)

    get :show, year: conference.year, reviewer_id: reviewer.id

    expect(assigns(:reviewer).preferences.size).to eq(1)
  end

  it 'show action should only assign audience levels for current conference' do
    get :show, year: conference.year, reviewer_id: reviewer.id

    expect(assigns(:audience_levels)).to eq([@audience_level])
  end

  it 'update action should render accept_reviewers/show template when model is invalid' do
    patch :update, year: conference.year, reviewer_id: reviewer.id, reviewer: {}

    expect(response).to render_template('accept_reviewers/show')
  end
  let(:other_track) { FactoryGirl.create(:track, conference: conference) }
  let(:valid_params) do
    {
      reviewer_agreement: '1',
      sign_reviews: '0',
      preferences_attributes: { '0' =>
        {
          accepted: '1',
          audience_level_id: @audience_level.id,
          track_id: @track.id
        }, '1' =>
        {
          accepted: '0',
          track_id: other_track.id
        } }
    }
  end
  it 'update action should redirect when model is valid' do
    patch :update, year: conference.year, reviewer_id: reviewer.id, reviewer: valid_params

    expect(response).to redirect_to(reviewer_sessions_path(conference))
  end
end
