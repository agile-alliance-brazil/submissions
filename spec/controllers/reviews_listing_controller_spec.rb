# frozen_string_literal: true

require 'spec_helper'

describe ReviewsListingController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :reviewer

  describe '#index' do
    before(:each) do
      user = FactoryGirl.create(:user)
      sign_in user
      disable_authorization
      @conference = FactoryGirl.create(:conference)
      Conference.stubs(:current).returns(@conference)
    end

    it 'index action (JS) should render JSON for early reviews' do
      @conference.stubs(:in_early_review_phase?).returns(true)
      @conference.presubmissions_deadline = DateTime.now

      sessions = FactoryGirl.create_list(:session, 2, created_at: @conference.presubmissions_deadline - 1.day)
      FactoryGirl.create(:session, created_at: @conference.presubmissions_deadline + 1.day)

      FactoryGirl.create(:early_review, session: sessions[0])

      xhr :get, :index, format: :js

      expect(response.body).to eq({
        'required_reviews' => 2,
        'total_reviews' => 1
      }.to_json)
    end

    it 'index action (JS) should render JSON for final reviews' do
      @conference.stubs(:in_early_review_phase?).returns(false)
      FactoryGirl.create_list(:final_review, 2)

      xhr :get, :index, format: :js

      expect(response.body).to eq({
        'required_reviews' => 6,
        'total_reviews' => 2
      }.to_json)
    end
  end

  context 'as a reviewer' do
    before(:each) do
      @reviewer = FactoryGirl.create(:reviewer)
      @conference = @reviewer.conference
      sign_in @reviewer.user
      disable_authorization
    end

    it 'index action should redirect to reviewer action' do
      get :index
      expect(response).to redirect_to(reviewer_reviews_url(@conference))
    end

    it 'reviewer action should render reviewer template' do
      get :reviewer
      expect(response).to render_template(:reviewer)
    end
  end
end
