# encoding: UTF-8
# frozen_string_literal: true

require 'spec_helper'

describe UsersController, type: :controller do
  fixtures :users
  let(:user) { FactoryGirl.create(:user) }
  # TODO: Shouldn't need a conference to render
  before do
    FactoryGirl.create(:conference)
  end

  context 'with views' do
    render_views
    it 'show should work' do
      get :show, id: user.id
    end
  end

  describe '#index' do
    describe 'with json format' do
      before do
        xhr :get, :index, format: :json, term: 'dt'
      end

      subject { response }

      its(:content_type) { should == 'application/json' }
    end
  end

  describe '#show' do
    before do
      get :show, id: user.id
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
  end
end
