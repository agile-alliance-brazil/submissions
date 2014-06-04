# encoding: UTF-8
require 'spec_helper'
 
describe SessionTypesController, type: :controller do
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end  
  
  it "index action should assign session types for current conference" do
    get :index
    (assigns(:session_types) - Conference.current.session_types).should be_empty
  end

end
