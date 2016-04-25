# encoding: UTF-8
require 'spec_helper'

describe TracksController, type: :controller do
  render_views

  let(:conference) { FactoryGirl.create(:conference) }
  let(:track) { FactoryGirl.create(:track, conference: conference) }
  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  context 'index action' do
    it 'should render index template' do
      get :index, year: track.conference.year

      expect(response).to render_template(:index)
    end

    it 'should assign tracks for current conference' do
      get :index, year: track.conference.year

      expect(assigns(:tracks)).to eq([track])
    end
  end
end
