# frozen_string_literal: true

require 'spec_helper'

describe ReviewerSessionsController, type: :controller do
  before do
    @reviewer ||= FactoryBot.create(:reviewer)
    sign_in @reviewer.user
    controller.stubs(:current_user).returns(@reviewer.user)
    disable_authorization
  end

  describe 'with view rendering', render_views: true do
    render_views

    it 'index should work' do
      get :index
    end
  end

  it_should_require_login_for_actions :index

  describe '#index' do
    let(:conference) do
      conference = @reviewer.conference
      conference.presubmissions_deadline = Time.now + 1.day
      conference
    end
    let!(:session_filter) { SessionFilter.new } # Mocha stubs before evaluating the param
    let(:session) { FactoryBot.build(:session, conference: conference) }

    before do
      Conference.stubs(:current).returns(conference)
      SessionFilter.stubs(:new).returns(session_filter)
      session_filter.stubs(:apply).returns([session])
    end

    it 'assigns tracks for current conference' do
      get :index
      expect(assigns(:tracks) - conference.tracks).to be_empty
    end

    it 'assigns audience levels for current conference' do
      get :index
      expect(assigns(:audience_levels) - conference.audience_levels).to be_empty
    end

    it 'assigns session types for current conference' do
      get :index
      expect(assigns(:session_types) - conference.session_types).to be_empty
    end

    it 'filters sessions' do
      filter_params = { 'audience_level_id' => '1', 'session_type_id' => '2', 'conference' => conference }
      filter = SessionFilter.new(filter_params, @reviewer.user)
      SessionFilter.expects(:new).with(filter_params).returns(filter)

      get :index, session_filter: filter_params
    end

    context 'during early review phase' do
      it 'should scope sessions for reviewer'
      it 'should order sessions from less reviewed to more early reviewed'
    end

    context 'during final review phase' do
      it 'should scope sessions for reviewer'
      it 'should order sessions from less reviewed to more final reviewed'
    end

    context 'outside of review phase' do
      it 'should scope to no sessions'
    end
  end
end
