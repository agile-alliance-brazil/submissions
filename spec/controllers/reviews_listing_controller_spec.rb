# encoding: UTF-8
require 'spec_helper'

describe ReviewsListingController do
  render_views

  it_should_require_login_for_actions :index, :reviewer

  describe "#index" do
    before(:each) do
      user = FactoryGirl.create(:user)
      sign_in user
      disable_authorization
      @conference = Conference.current
    end

    it "index action (JS) should render JSON for final reviews" do
      @conference.expects(:in_final_review_phase?).returns(false)
      @conference.expects(:in_early_review_phase?).returns(true)

      FactoryGirl.create_list(:early_review, 2)

      get :index, :format => 'js'

      response.body.should == {
        'required_reviews' => 2,
        'total_reviews' => 2
      }.to_json
    end

    it "index action (JS) should render JSON for final reviews" do
      @conference.expects(:in_final_review_phase?).returns(true)
      @conference.expects(:in_early_review_phase?).returns(false)
      FactoryGirl.create_list(:final_review, 2)

      get :index, :format => 'js'

      response.body.should == {
        'required_reviews' => 6,
        'total_reviews' => 2
      }.to_json
    end
  end

  context "as a reviewer" do
    before(:each) do
      @reviewer = FactoryGirl.create(:reviewer)
      sign_in @reviewer.user
      disable_authorization
    end

    it "index action should redirect to reviewer action" do
      get :index
      response.should redirect_to(reviewer_reviews_url(Conference.current))
    end

    it "reviewer action should render reviewer template" do
      get :reviewer
      response.should render_template(:reviewer)
    end
  end
end
