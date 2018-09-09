# frozen_string_literal: true

require 'spec_helper'

describe RejectReviewersController, type: :controller do
  render_views

  it_should_require_login_for_actions :show, :update

  before do
    @user ||= FactoryBot.create(:user)
    @reviewer ||= FactoryBot.create(:reviewer, user: @user)
    Reviewer.stubs(:find).returns(@reviewer)
    sign_in @user
    disable_authorization
  end

  it 'show action should render show template' do
    get :show, reviewer_id: @reviewer.id
    expect(response).to render_template(:show)
  end

  it 'update action should render show template when transition is invalid' do
    @reviewer.expects(:reject).returns(false)

    patch :update, reviewer_id: @reviewer.id

    expect(response).to render_template(:show)
  end

  it 'update action should redirect when transition is valid' do
    patch :update, reviewer_id: @reviewer.id

    expect(response).to redirect_to(root_path)
  end
end
