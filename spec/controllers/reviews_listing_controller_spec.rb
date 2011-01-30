require 'spec/spec_helper'
 
describe ReviewsListingController do
  integrate_views

  it_should_require_login_for_actions :index, :reviewer

  it "index action (JS) should render JSON" do
    # Login
    user = Factory(:user)
    activate_authlogic
    UserSession.create(user)
    
    # 2 reviews (2 sessions)
    Factory(:review)
    Factory(:review)
    
    get :index, :format => 'js'
    response.body.should == {
      'total_reviews' => 2,
      'required_reviews' => 6
    }.to_json
  end
  
  context "as a reviewer" do
    before(:each) do
      @reviewer = Factory(:reviewer)
      activate_authlogic
      UserSession.create(@reviewer.user)
    end
    
    it "index action should redirect to reviewer action" do
      get :index
      response.should redirect_to(reviewer_reviews_url)
    end

    it "reviewer action should render reviewer template" do
      get :reviewer
      response.should render_template(:reviewer)
    end
  end
end
