# frozen_string_literal: true

require 'spec_helper'

describe VotesController, type: :controller do
  render_views

  it 'show should work' do
    get :index
  end
end

describe VotesController, type: :controller do
  it_should_require_login_for_actions :index, :create, :destroy

  before do
    @vote ||= FactoryBot.create(:vote)
    sign_in @vote.user
    disable_authorization
  end

  describe '#index' do
    subject { assigns(:sessions) }

    before { get :index }

    it { is_expected.to eq([@vote.session]) }
  end

  describe '#create' do
    before do
      @session = FactoryBot.create(:session)
      @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
      post :create, vote: { session_id: @session.id }
    end

    it { is_expected.to redirect_to('http://test.com/sessions/new') }
    it { expect(@session.votes).not_to be_empty }
  end

  describe '#destroy' do
    before do
      @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
      delete :destroy, id: @vote.id
    end

    it { is_expected.to redirect_to('http://test.com/sessions/new') }
    it { expect(-> { Vote.find(@vote.id) }).to raise_error(ActiveRecord::RecordNotFound) }
  end
end
