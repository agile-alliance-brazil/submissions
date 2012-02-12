# encoding: UTF-8
require 'spec_helper'
 
describe UsersController do
  render_views
  
  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  it "index should render JS with a list of matching usernames" do
    get :index, :format => :js, :q => 'dt'
    response.should render_template('users/index')
  end

  it "index action should redirect to new registration for HTML format" do
    get :index
    response.should redirect_to(new_user_registration_path)
  end

  it "show action should render show template" do
    get :show, :id => User.first
    response.should render_template(:show)
  end
end
