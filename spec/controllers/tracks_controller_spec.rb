# encoding: UTF-8
require 'spec_helper'
 
describe TracksController do
  fixtures :all
  render_views

  before(:each) do
    FactoryGirl.build(:track)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end  

end
