require 'spec/spec_helper'
 
describe ReviewListingController do
  integrate_views

  it_should_require_login_for_actions :reviewer

  before(:each) do
    @reviewer = Factory(:reviewer)
    activate_authlogic
    UserSession.create(@reviewer.user)
  end

  it "reviewer action should render reviewer template" do
    get :reviewer
    response.should render_template(:reviewer)
  end
end
