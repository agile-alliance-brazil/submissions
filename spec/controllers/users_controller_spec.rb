# frozen_string_literal: true

require 'spec_helper'

describe UsersController, type: :controller do
  fixtures :users
  let(:user) { FactoryBot.create(:user) }
  # TODO: Shouldn't need a conference to render

  before do
    FactoryBot.create(:conference)
  end

  context 'with views' do
    render_views
    it 'show should work' do
      get :show, id: user.id
    end
  end

  describe '#index' do
    describe 'with json format' do
      subject { response }

      before do
        xhr :get, :index, format: :json, term: 'dt'
      end

      its(:content_type) { is_expected.to eq('application/json') }
    end
  end

  describe '#show' do
    before do
      get :show, id: user.id
    end

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:show) }
  end
end
