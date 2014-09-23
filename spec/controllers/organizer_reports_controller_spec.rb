# encoding: UTF-8
require 'spec_helper'

describe OrganizerReportsController, type: :controller do

  before(:each) do
    @organizer = FactoryGirl.create(:organizer)
    @conference = @organizer.conference
    sign_in @organizer.user
    disable_authorization
  end

  describe "with view rendering", render_views: true do
    render_views

    it "index should work" do
      get :index, format: :xls
    end
  end

  it_should_require_login_for_actions :index

  describe "#index" do
    before(:each) do
      @session = FactoryGirl.build(:session)
      Session.stubs(:for_conference).returns(Session)
      Session.stubs(:for_tracks).returns(Session)
      Session.stubs(:includes).returns([@session])
    end

    it "should report sessions on organizer's tracks" do
      Session.expects(:for_tracks).with([@organizer.track.id]).returns(Session)

      get :index, format: :xls
      expect(assigns(:sessions)).to eq([@session])
    end
  end
end
