# encoding: UTF-8
require 'spec_helper'
 
describe AudienceLevelsController, type: :controller do
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should assign audience levels for current conference" do
    get :index
    (assigns(:audience_levels) - Conference.current.audience_levels).should be_empty
  end
end
