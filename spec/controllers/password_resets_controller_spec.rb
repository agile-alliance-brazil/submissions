require 'spec_helper'

describe PasswordResetsController do
  render_views

  it_should_require_logout_for_actions :index, :new, :create, :edit, :update
  
  before(:each) do
    @user = Factory(:user)
    User.stubs(:find_using_perishable_token).returns(@user)
  end

  it "index action should redirect to new" do
    get :index
    response.should render_template(:new)
  end


  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "edit action should render edit template" do
    get :edit, :id => @user
    response.should render_template(:edit)
  end
end
