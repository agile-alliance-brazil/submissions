# encoding: UTF-8
require 'spec_helper'
 
describe TracksController, type: :controller do
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "index action should assign tracks for current conference" do
    get :index
    (assigns(:tracks) - Conference.current.tracks).should be_empty
  end
end
