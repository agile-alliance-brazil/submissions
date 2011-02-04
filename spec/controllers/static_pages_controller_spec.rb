require 'spec_helper'

describe StaticPagesController do
  it "should route to guidelines page" do
    {:get => '/guidelines'}.should route_to(:controller => 'static_pages', :action => 'show', :page => 'guidelines')
  end

  it "should render template from page param" do
    get :show, :page => 'syntax_help'
    response.should render_template('static_pages/syntax_help')
  end
end
