# frozen_string_literal: true

require 'spec_helper'

describe OrganizerSessionsController, type: :controller do
  before(:each) do
    @conference = FactoryGirl.create(:conference)
    # TODO: Improve conference usage
    Conference.stubs(:current).returns(@conference)
    @track = FactoryGirl.create(:track, conference: @conference)
    @organizer = FactoryGirl.create(:organizer, track: @track, conference: @conference)
    sign_in @organizer.user
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
    before(:each) do
      @session = FactoryGirl.build(:session)
      SessionFilter.any_instance.stubs(:apply).returns([@session])
    end

    it 'should assign tracks for current conference' do
      get :index
      expect((assigns(:tracks) - Track.for_conference(@conference))).to be_empty
    end

    it 'should assign session states' do
      get :index
      expect(assigns(:states)).to eq(Session.state_machine.states.map(&:name))
    end

    it 'should filter sessions based on filter'

    it "should find sessions on organizer's tracks" do
      Session.expects(:for_tracks).with([@organizer.track.id]).returns(Session)

      get :index
      expect(assigns(:sessions)).to eq([@session])
    end
  end
end
