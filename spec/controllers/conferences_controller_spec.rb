# encoding: UTF-8
require 'spec_helper'

describe ConferencesController, type: :controller do
  it_should_require_login_for_actions :index, :new, :create, :edit, :update, :destroy

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { user.tap {|u| u.add_role(:admin); u.save } }
  let(:valid_conference_params) do
    {
      location: 'Chicago IL',
      start_date: '9999-03-01',
      end_date: '9999-03-05',
      submissions_open: '9998-07-01',
      presubmissions_deadline: '9998-07-31',
      prereview_deadline: '9998-08-30',
      submissions_deadline: '9998-09-31',
      voting_deadline: '9998-10-15',
      review_deadline: '9998-10-30',
      author_notification: '9998-11-31',
      author_confirmation: '9998-12-15',
      visible: false
    }
  end
  subject { FactoryGirl.create(:conference) }

  before(:each) do
    sign_in admin
    disable_authorization
  end

  context 'index action' do
    it 'should render all conferences' do
      new_conf = FactoryGirl.create(:conference)

      get :index

      expect(assigns(:conferences)).to eq(Conference.all.sort_by(&:created_at).reverse)
    end
  end

  context 'new action' do
    it 'should render new template' do
      get :new

      expect(response).to render_template('conferences/new')
    end

    it 'should assign empty conference without attributes' do
      get :new

      expect(assigns(:conference).attributes).to eq(Conference.new.attributes)
    end

    it 'should assign conference with provided attributes if any' do
      get :new, conference: { name: 'My test' }

      expect(assigns(:conference).name).to eq('My test')
    end
  end

  context 'create action' do
    it 'should redirect when model is valid' do
      post :create, conference: { year: 9999, name: "Agile Brazil 9999", program_chair_user_username: user.username }

      expect(response).to redirect_to("/9999")
    end
  end

  context 'edit action' do
    it 'should render edit template' do
      get :edit, id: subject.year

      expect(response).to render_template(:edit)
    end

    it 'should assign existing conference' do
      get :edit, id: subject.year

      expect(assigns(:conference)).to eq(subject)
    end
  end

  context 'update action' do
    it 'should render edit template when model is invalid' do
      patch :update, id: subject.year, conference: { start_date: Time.zone.now }

      expect(assigns(:conference)).to eq(subject)
      expect(assigns(:conference).errors).to_not be_empty
      expect(response).to render_template(:edit)
    end

    it 'should redirect when model is valid' do
      patch :update, id: subject.year, conference: valid_conference_params

      expect(assigns(:conference).errors).to be_empty
      expect(response).to redirect_to("/#{subject.year}")
    end

    it 'should update from invisible to visible' do
      subject.tap{|c| c.visible=false; c.save}

      patch :update, id: subject.year, conference: valid_conference_params.merge(visible: true)

      expect(subject.reload).to be_visible
    end

    it 'should not update from visible to invisible' do
      patch :update, id: subject.year, conference: valid_conference_params.merge(visible: false)

      expect(subject.reload).to be_visible
    end
  end

  context "with views" do
    render_views

  end
end
