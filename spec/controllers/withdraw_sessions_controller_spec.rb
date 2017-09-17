# frozen_string_literal: true

require 'spec_helper'

describe WithdrawSessionsController, type: :controller do
  render_views

  it_should_require_login_for_actions :show, :update

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    @session ||= FactoryGirl.create(:session, author: @user)
    @conference ||= @session.conference
    @session.reviewing
    FactoryGirl.create(:review_decision, session: @session)
    @session.tentatively_accept
    Session.stubs(:find).returns(@session)
    sign_in @user
    disable_authorization
  end

  it 'show action should render show template' do
    get :show, session_id: @session.id
    expect(response).to render_template(:show)
  end

  it 'update action should render show template when model is invalid' do
    patch :update, session_id: @session.id, session: { author_agreement: '0' }

    expect(response).to render_template(:show)
  end

  it 'update action should redirect when model is valid' do
    patch :update, session_id: @session.id, session: { author_agreement: '1' }

    expect(response).to redirect_to(user_sessions_path(@conference, @user))
  end
end
