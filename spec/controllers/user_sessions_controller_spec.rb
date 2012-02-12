# encoding: UTF-8
require 'spec_helper'
 
describe UserSessionsController do
  fixtures :users
  render_views
  it_should_behave_like_a_devise_controller
  
  before do
    Factory(:conference)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template('static_pages/home')
  end
end
