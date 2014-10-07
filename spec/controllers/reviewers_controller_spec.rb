# encoding: UTF-8
require 'spec_helper'

describe ReviewersController, type: :controller do
  it_should_require_login_for_actions :index, :destroy, :create

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    # TODO: Improve use of conference
    @conference ||= FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)
    sign_in @user
    disable_authorization
    EmailNotifications.stubs(:reviewer_invitation).returns(stub(deliver: true))
  end

  context 'index' do
    before(:each) do
      @track ||= FactoryGirl.create(:track, conference: @conference)
      FactoryGirl.create(:track, conference: FactoryGirl.create(:conference))
      @reviewers = [FactoryGirl.create(:reviewer, conference: @conference),FactoryGirl.create(:reviewer, conference: @conference),]
    end
    it "index action should render index template" do
      get :index, year: @conference.year
      expect(response).to render_template(:index)
    end

    it "index action should assign tracks for current conference" do
      get :index, year: @conference.year
      expect(assigns(:tracks)).to eq([@track])
    end

    it "index action should assign states for current conference" do
      get :index, year: @conference.year
      expect(assigns(:states)).to eq([:created, :invited, :accepted, :rejected])
    end

    it "index action should assign reviewers for current conference" do
      get :index, year: @conference.year
      expect(assigns(:reviewers)).to eq(@reviewers)
    end

    it "index action should assign new reviewer for current conference" do
      reviewer = Reviewer.new(conference: @conference)
      Reviewer.expects(:new).with(conference: @conference).returns(reviewer)

      get :index, year: @conference.year

      expect(assigns(:reviewer)).to eq(reviewer)
    end
  end

  context 'create' do
    before(:each) do
      @new_reviewer_user = FactoryGirl.create(:user)
    end
    context 'valid creation' do
      let(:valid_params) {
        { reviewer:
          { user_username: @new_reviewer_user.username, year: @conference.year }
        }
      }
      it "should allow only reviewer username" do
        valid_params[:reviewer][:state] = 'accepted'
        post :create, valid_params

        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['reviewer']['status']).to eq(I18n.t("reviewer.state.invited"))
      end
      it "should return success message upon creation" do
        post :create, valid_params

        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t("flash.reviewer.create.success"))
      end
      context 'regarding response data' do
        subject { post :create, valid_params; JSON.parse(response.body)['reviewer'] }
        it { should have_key('id') }
        it { should include('full_name' => @new_reviewer_user.full_name) }
        it { should include('username' => @new_reviewer_user.username) }
        it { should include('status' => I18n.t("reviewer.state.invited")) }
        it { should include('url' => reviewer_path(@conference, id: subject['id'])) }
      end
    end
    context 'invalid creation' do
      it 'should return 400 for invalid creation' do
        post :create

        expect(response.status).to eq(400)
      end
      it 'should show error message for invalid user' do
        post :create, reviewer: {user_username: 'a'}

        expect(response.body).to eq(
          I18n.t('flash.reviewer.create.failure', username: 'a')
        )
      end
      it 'should show text message for no reviewer' do
        post :create

        expect(response.body).to eq('Required parameter missing: reviewer')
      end
      it 'should show error message for user that is already a reviewer' do
        FactoryGirl.create(:reviewer, conference: @conference, user_username: @new_reviewer_user.username)

        post :create, reviewer: {user_username: @new_reviewer_user.username}

        expect(response.body).to eq(
          I18n.t('flash.reviewer.create.failure', username: @new_reviewer_user.username)
        )
      end
    end
  end

  context 'show' do
    before(:each) do
      @reviewer = FactoryGirl.create(:reviewer, user_id: @user.id)
    end
    it 'should assign the reviewer according to the id' do
      get :show, id: @reviewer.id

      expect(assigns(:reviewer)).to eq(@reviewer)
    end
  end

  context 'destroy' do
    context 'valid reviewer' do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer, user_id: @user.id)
      end
      it "should render message" do
        delete :destroy, id: @reviewer.id, year: @conference.year

        expect(JSON.parse(response.body)['message']).to eq(
          I18n.t('flash.reviewer.destroy.success', full_name: @user.full_name)
        )
      end
      it "should return 200" do
        delete :destroy, id: @reviewer.id, year: @conference.year

        expect(response.status).to eq(200)
      end
    end
    context 'invalid reviewer' do
      before(:each) do
        @id = (Reviewer.last.try(:id) || 0) + 1
      end
      it "should render not found message" do
        delete :destroy, id: @id, year: @conference.year

        expect(response.body).to eq('not-found')
      end
      it "should return 404" do
        delete :destroy, id: @id, year: @conference.year

        expect(response.status).to eq(404)
      end
    end
  end
end
