# frozen_string_literal: true

require 'spec_helper'

describe OrganizerReportsController, type: :controller do
  let(:conference) { FactoryBot.create(:conference) }
  let(:organizer) { FactoryBot.create(:organizer, conference: conference) }

  before do
    sign_in organizer.user
    disable_authorization
  end

  describe 'with view rendering', render_views: true do
    render_views

    it 'index should work' do
      get :index, format: :xls, year: conference.year
    end
  end

  it_should_require_login_for_actions :index

  describe '#index' do
    let(:session) { FactoryBot.build(:session, conference: conference, track: organizer.track) }

    before do
      Session.stubs(:for_conference).returns(Session)
      Session.stubs(:for_tracks).returns(Session)
      Session.stubs(:includes).returns([session])
    end

    it "reports sessions on organizer's tracks" do
      Session.expects(:for_tracks).with([organizer.track.id]).returns(Session)

      get :index, format: :xls, year: conference.year
      expect(assigns(:sessions)).to eq([session])
    end
  end
end
