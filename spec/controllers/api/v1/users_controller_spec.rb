# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::UsersController, type: :controller do
  let(:user)  { FactoryBot.create(:user) }
  let(:token) { stub(acceptable?: true, resource_owner_id: user.id) }

  before      { controller.stubs(:doorkeeper_token).returns(token) }

  describe 'show' do
    before do
      get :show, format: :json
    end

    it { is_expected.to respond_with(:success) }

    it 'returns user JSON representation' do
      expect(JSON.parse(response.body)).to eq('id' => user.id,
                                              'first_name' => user.first_name,
                                              'last_name' => user.last_name,
                                              'username' => user.username,
                                              'email' => user.email,
                                              'organization' => user.organization,
                                              'city' => user.city,
                                              'country' => user.country,
                                              'state' => user.state,
                                              'reviewer?' => user.reviewer?,
                                              'organizer?' => user.organizer?,
                                              'twitter_username' => user.twitter_username,
                                              'phone' => user.phone,
                                              'default_locale' => user.default_locale)
    end
  end

  describe 'make_voter' do
    before do
      post :make_voter, format: :json
    end

    it { is_expected.to respond_with(:success) }

    it 'makes user a voter' do
      expect(user.reload).to be_voter
    end

    it 'returns success JSON' do
      expect(JSON.parse(response.body)).to eq('success' => true, 'vote_url' => sessions_url)
    end
  end
end
