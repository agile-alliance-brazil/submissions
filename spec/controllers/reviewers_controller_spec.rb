# frozen_string_literal: true

require 'spec_helper'

describe ReviewersController, type: :controller do
  it_should_require_login_for_actions :index, :destroy, :create
  let(:user) { FactoryBot.create(:user) }
  let(:conference) { FactoryBot.create(:conference) }

  before do
    # TODO: Improve use of conference
    Conference.stubs(:current).returns(conference)
    sign_in user
    disable_authorization
    EmailNotifications.stubs(:reviewer_invitation).returns(stub(deliver_now: true))
  end

  context 'index' do
    let(:track) { FactoryBot.create(:track, conference: conference) }

    before do
      FactoryBot.create(:track, conference: FactoryBot.create(:conference))
      @reviewers = [
        FactoryBot.create(:reviewer, conference: conference),
        FactoryBot.create(:reviewer, conference: conference)
      ]
    end

    it 'index action should render index template' do
      get :index, year: conference.year

      expect(response).to render_template(:index)
    end

    it 'index action should assign tracks for current conference' do
      expected_tracks = [track] # need to force creation

      get :index, year: conference.year

      expect(assigns(:tracks)).to eq(expected_tracks)
    end

    it 'index action should assign states for current conference' do
      get :index, year: conference.year

      expect(assigns(:states)).to eq(%i[created invited accepted rejected])
    end

    it 'index action should assign reviewers for current conference' do
      get :index, year: conference.year

      expect(assigns(:reviewers).sort).to eq(@reviewers)
    end

    it 'index action should assign new reviewer for current conference' do
      reviewer = Reviewer.new(conference: conference)
      Reviewer.expects(:new).with(conference: conference).returns(reviewer)

      get :index, year: conference.year

      expect(assigns(:reviewer)).to eq(reviewer)
    end

    context 'filtering' do
      it 'filters the index by state' do
        reviewer = @reviewers.first
        reviewer.reject

        get :index, year: conference.year, reviewer_filter: { state: :rejected }

        expect(assigns(:reviewers)).not_to be_nil
        expect(assigns(:reviewers).size).to eq(1)
        expect(assigns(:reviewers)).to include(reviewer)
      end
    end
  end

  context 'create' do
    let(:valid_params) { { user_username: user.username } }

    context 'valid creation' do
      it 'allows only reviewer username' do
        params = valid_params
        params[:state] = 'accepted'

        post :create, year: conference.year, format: 'json', reviewer: params

        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['reviewer']['status']).to eq(I18n.t('reviewer.state.invited'))
      end
      it 'returns success message upon creation' do
        post :create, year: conference.year, format: 'json', reviewer: valid_params

        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('flash.reviewer.create.success'))
      end
      context 'regarding response data' do
        subject do
          post :create, year: conference.year, format: 'json', reviewer: valid_params
          JSON.parse(response.body)['reviewer']
        end

        it { is_expected.to have_key('id') }
        it { is_expected.to include('full_name' => user.full_name) }
        it { is_expected.to include('username' => user.username) }
        it { is_expected.to include('status' => I18n.t('reviewer.state.invited')) }
        it { is_expected.to include('url' => reviewer_path(conference, id: subject['id'])) }
      end
    end

    context 'invalid creation' do
      it 'returns 400 for invalid creation' do
        post :create, format: 'json'

        expect(response.status).to eq(400)
      end
      it 'shows error message for invalid user' do
        post :create, format: 'json', reviewer: { user_username: 'a' }

        expect(response.body).to eq(
          I18n.t('flash.reviewer.create.failure', username: 'a')
        )
      end
      it 'shows text message for no reviewer' do
        post :create, format: 'json'

        expect(response.body).to eq(I18n.t('flash.reviewer.create.failure', username: ''))
      end
      it 'shows error message for user that is already a reviewer' do
        FactoryBot.create(:reviewer, conference: conference, user_username: user.username)

        post :create, format: 'json', reviewer: { user_username: user.username }

        expect(response.body).to eq(
          I18n.t('flash.reviewer.create.failure', username: user.username)
        )
      end
    end
  end

  context 'show' do
    subject { FactoryBot.create(:reviewer, user_id: user.id) }

    it 'assigns the reviewer according to the id' do
      get :show, id: subject.id

      expect(assigns(:reviewer)).to eq(subject)
    end
  end

  context 'destroy' do
    context 'valid reviewer' do
      subject { FactoryBot.create(:reviewer, user_id: user.id) }

      it 'renders message' do
        delete :destroy, id: subject.id, year: conference.year, format: 'json'

        expect(JSON.parse(response.body)['message']).to eq(
          I18n.t('flash.reviewer.destroy.success', full_name: user.full_name)
        )
      end
      it 'returns 200' do
        delete :destroy, id: subject.id, year: conference.year, format: 'json'

        expect(response.status).to eq(200)
      end
    end

    context 'invalid reviewer' do
      before do
        @id = (Reviewer.last.try(:id) || 0) + 1
      end

      it 'renders not found message' do
        delete :destroy, id: @id, year: conference.year, format: 'json'

        expect(response.body).to eq('not-found')
      end
      it 'returns 404' do
        delete :destroy, id: @id, year: conference.year, format: 'json'

        expect(response.status).to eq(404)
      end
    end
  end
end
