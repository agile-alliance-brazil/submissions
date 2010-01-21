require 'spec/spec_helper'
 
describe TagsController do
  integrate_views
  
  it "index action should render index template" do
    get :index, :format => :js
    response.should render_template(:index)
  end
end
