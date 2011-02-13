require 'spec_helper'
 
describe ReviewsListingController do
  render_views

  it_should_require_login_for_actions :index, :reviewer

  it "index action (JS) should render JSON" do
    # Login
    user = Factory(:user)
    activate_authlogic
    UserSession.create(user)
    disable_authorization

    # 2 reviews (2 sessions)
    review = Factory(:review)
    Factory(:review, :session => Factory(:session, :conference => review.session.conference))
    
    get :index, :format => 'js'
    response.body.should == {
      'required_reviews' => 6,
      'total_reviews' => 2
    }.to_json
  end
  
  context "as a reviewer" do
    before(:each) do
      @reviewer = Factory(:reviewer)
      activate_authlogic
      UserSession.create(@reviewer.user)
      disable_authorization
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
