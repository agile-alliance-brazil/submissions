# encoding: UTF-8
require 'spec_helper'

describe AcceptedSessionsController, type: :controller do
  render_views

  it "index should work" do
    FactoryGirl.create_list(:session, 3)
    get :index
  end
end

describe AcceptedSessionsController, type: :controller do
  describe "#index" do
    it "should fetch all activities" do
      start_time = Time.zone.now
      conference = FactoryGirl.create(:conference, year: start_time.year)
      activity = FactoryGirl.create(:activity, start_at: start_time)
      get :index, year: conference.year
      expect(assigns(:activities)).to eq([activity])
    end
  end
end
