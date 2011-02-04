require 'spec_helper'
 
describe AcceptedSessionsController do
  render_views

  it_should_require_login_for_actions :index

  before(:each) do
    user = Factory(:user)
    activate_authlogic
    UserSession.create(user)
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
end