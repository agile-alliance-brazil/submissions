# encoding: UTF-8
require 'spec_helper'

describe StaticPagesController do
  it "should route to guidelines page" do
    {:get => '/guidelines', :year => 2010}.should route_to(:controller => 'static_pages', :action => 'show', :page => '2010_guidelines')
  end

  it "should render template from page param" do
    get :show, :page => 'syntax_help', :year => 2011
    response.should render_template('static_pages/2011_syntax_help')
  end
end
