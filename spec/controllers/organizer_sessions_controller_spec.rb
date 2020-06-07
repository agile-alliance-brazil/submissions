# frozen_string_literal: true

require 'spec_helper'

describe OrganizerSessionsController, type: :controller do
  let(:conference) { FactoryBot.create(:conference) }
  let(:track) { FactoryBot.create(:track, conference: conference) }
  let(:organizer) { FactoryBot.create(:organizer, track: track, conference: conference) }

  before do
    # TODO: Improve conference usage
    Conference.stubs(:current).returns(conference)
    sign_in organizer.user
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
    let(:session) { FactoryBot.build(:session) }
    let!(:session_filter) { SessionFilter.new } # Mocha stubs before evaluating the param

    before do
      SessionFilter.stubs(:new).returns(session_filter)
    end

    it 'assigns tracks for current conference' do
      session_filter.stubs(:apply).returns([session])
      get :index
      expect((assigns(:tracks) - Track.for_conference(conference))).to be_empty
    end

    it 'assigns session states' do
      session_filter.stubs(:apply).returns([session])
      get :index
      expect(assigns(:states)).to eq(Session.state_machine.states.map(&:name))
    end

    it 'should filter sessions based on filter'

    it "finds sessions on organizer's tracks" do
      session_filter.stubs(:apply).returns([session])
      Session.expects(:for_tracks).with([organizer.track.id]).returns(Session)

      get :index
      expect(assigns(:sessions)).to eq([session])
    end
  end
end
