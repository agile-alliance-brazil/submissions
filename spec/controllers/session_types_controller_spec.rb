# encoding: UTF-8
require 'spec_helper'
 
describe SessionTypesController do
  fixtures :all
  render_views

  before(:each) do
    FactoryGirl.build(:session_type)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end  

end
