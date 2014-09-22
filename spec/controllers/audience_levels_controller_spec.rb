# encoding: UTF-8
require 'spec_helper'
 
describe AudienceLevelsController, type: :controller do
  render_views

  before(:each) do
    @conference = FactoryGirl.create(:conference)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end
  
  it "index action should assign audience levels for current conference" do
    get :index
    expect((assigns(:audience_levels) - @conference.audience_levels)).to be_empty
  end
end
