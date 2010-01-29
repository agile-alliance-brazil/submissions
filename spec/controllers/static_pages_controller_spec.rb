require 'spec/spec_helper'

describe StaticPagesController do
  it "should route to guidelines page" do
    {:get => '/guidelines'}.should route_to(:controller => 'static_pages', :action => 'show', :page => 'guidelines')
  end

  it "should render template from page param" do
    get :show, :page => 'guidelines'
    response.should render_template('static_pages/guidelines')
  end
end
