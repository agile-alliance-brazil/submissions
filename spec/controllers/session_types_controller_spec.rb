require 'spec/spec_helper'
 
describe SessionTypesController do
  fixtures :all
  integrate_views

  before(:each) do
    Factory(:session_type)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end  

end
