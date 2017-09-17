# frozen_string_literal: true

require 'spec_helper'

describe PasswordResetsController, type: :controller do
  render_views
  it_should_behave_like_a_devise_controller

  before(:each) do
    @user = FactoryGirl.build(:user)
    # TODO: Remove conference dependency
    FactoryGirl.create(:conference)
  end

  it 'new action should render new template' do
    get :new
    expect(response).to render_template(:new)
  end

  it 'edit action should render edit template' do
    get :edit, id: @user, reset_password_token: 'aaaa'
    expect(response).to render_template(:edit)
  end
end
