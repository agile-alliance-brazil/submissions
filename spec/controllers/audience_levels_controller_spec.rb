# encoding: UTF-8
require 'spec_helper'
 
describe AudienceLevelsController do
  fixtures :all
  render_views

  before(:each) do
    FactoryGirl.build(:audience_level)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
end
