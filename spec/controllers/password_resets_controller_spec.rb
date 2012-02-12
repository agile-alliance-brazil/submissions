# encoding: UTF-8
require 'spec_helper'

describe PasswordResetsController do
  render_views
  it_should_behave_like_a_devise_controller

  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "edit action should render edit template" do
    get :edit, :id => @user, :reset_password_token => 'aaaa'
    response.should render_template(:edit)
  end
end
