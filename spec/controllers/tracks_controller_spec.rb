# encoding: UTF-8
require 'spec_helper'
 
describe TracksController, type: :controller do
  render_views

  before(:each) do
    @conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)
    @track = FactoryGirl.create(:track, conference: @conference)
    FactoryGirl.create(:track, conference: FactoryGirl.create(:conference))
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end
  
  it "index action should assign tracks for current conference" do
    get :index
    expect(assigns(:tracks)).to eq([@track])
  end
end
