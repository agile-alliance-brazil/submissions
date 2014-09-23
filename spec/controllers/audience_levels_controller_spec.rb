# encoding: UTF-8
require 'spec_helper'
 
describe AudienceLevelsController, type: :controller do
  render_views

  before(:each) do
    # TODO: Improve conference usage
    @conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)
    @audience_level = FactoryGirl.create(:audience_level, conference: @conference)
    FactoryGirl.create(:audience_level, conference: FactoryGirl.create(:conference))
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end
  
  it "index action should assign audience levels for current conference" do
    get :index
    expect(assigns(:audience_levels)).to eq([@audience_level])
  end
end
