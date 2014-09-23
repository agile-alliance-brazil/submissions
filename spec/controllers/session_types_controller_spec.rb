# encoding: UTF-8
require 'spec_helper'
 
describe SessionTypesController, type: :controller do
  render_views

  before(:each) do
    # TODO improve usage of conference
    @conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)
    @session_type = FactoryGirl.create(:session_type, conference: @conference)
    FactoryGirl.create(:session_type, conference: FactoryGirl.create(:conference))
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end  
  
  it "index action should assign session types for current conference" do
    get :index
    expect(assigns(:session_types)).to eq([@session_type])
  end

end
