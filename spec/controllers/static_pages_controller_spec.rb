# encoding: UTF-8
require 'spec_helper'

describe StaticPagesController, type: :controller do
  it "should route to guidelines page" do
    expect(get: '/2010/guidelines').to route_to(controller: 'static_pages',
        action: 'show',
        page: 'guidelines',
        year: '2010')
  end

  it "should render template from page param" do
    FactoryGirl.create(:conference, year: 2011)
    controller.stubs(:render)
    controller.expects(:render).with(action: '2011_syntax_help')

    get :show, page: 'syntax_help', year: 2011
  end
end
