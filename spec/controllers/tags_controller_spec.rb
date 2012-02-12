# encoding: UTF-8
require 'spec_helper'
 
describe TagsController do
  render_views
  
  it "index action should render index template" do
    get :index, :format => :js
    response.should render_template(:index)
  end
end
