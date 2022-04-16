# frozen_string_literal: true

require 'spec_helper'

describe RegistrationsController, type: :controller do
  render_views
  it_should_behave_like_a_devise_controller
  let!(:conference) { FactoryBot.create(:conference) } # TODO: Remove conference dependency

  describe 'GET #new' do
    before { get :new, locale: 'en' }

    it { expect(response).to render_template(:new) }
    it { expect(assigns(:user).default_locale.to_sym).to eq(:en) }
  end

  describe 'POST #create' do
    context 'when invalid' do
      before { post :create, user: User.new }

      it { expect(response).to render_template(:new) }
    end

    context 'when valid' do
      let!(:new_user) { FactoryBot.build(:user) }
      before do
        EmailNotifications.expects(:welcome).returns(mock(deliver_now: true))
        User.stubs(:new).returns(new_user)
        post :create, user: new_user
      end

      it { expect(response).to redirect_to(root_url) }
      it { expect(controller.current_user).not_to be_nil }
      it { expect(controller.current_user.reload.user_conferences).to have(1).items }
    end
  end

  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }
    before do
      user.user_conferences = []
      sign_in user
      disable_authorization
    end

    describe 'GET #edit' do
      context 'when profile review is not registered' do
        before { get :edit }

        it { expect(response).to render_template(:edit) }
        it { expect(assigns(:user).default_locale.to_sym).to eq(:'pt-BR') }
        it { expect(assigns(:user_profile_outdated)).to eq(true) }
      end
      describe 'when profile review is registered' do
        before do
          user.register_profile_review(Conference.current)
          get :edit
        end

        it { expect(assigns(:user_profile_outdated)).to eq(false) }
      end
    end

    describe 'PATCH #update' do
      context 'when invalid' do
        before { patch :update, id: user.id, user: { username: nil } }
        it { expect(response).to render_template(:edit) }
        it { expect(user.user_conferences).to have(0).item }
      end

      context 'when valid' do
        before do
          patch :update, user: {
            current_password: 'secret',
            password: 'newsecret',
            password_confirmation: 'newsecret'
          }
        end

        it { expect(response).to redirect_to(user_path(assigns(:user))) }
        it { expect(user.reload.user_conferences).to have(1).item }
      end
    end
  end
end
