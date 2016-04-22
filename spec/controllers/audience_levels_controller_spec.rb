# encoding: UTF-8
require 'spec_helper'

describe AudienceLevelsController, type: :controller do
  before(:each) do
    @conference = FactoryGirl.create(:conference)
    @audience_level = FactoryGirl.create(:audience_level, conference: @conference)
    FactoryGirl.create(:audience_level, conference: FactoryGirl.create(:conference))
  end

  it "index action should render index template" do
    get :index, year: @conference.year
    expect(response).to render_template(:index)
  end

  it "index action should assign audience levels for given conference" do
    get :index, year: @conference.year
    expect(assigns(:audience_levels)).to eq([@audience_level])
  end
end
