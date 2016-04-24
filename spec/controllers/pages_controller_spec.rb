# encoding: UTF-8
require 'spec_helper'

describe PagesController, type: :controller do
  it 'should route to guidelines page' do
    expect(get: '/2010/guidelines').to route_to(controller: 'pages',
        action: 'show',
        path: 'guidelines',
        year: '2010')
  end

  it 'should render static resource if page does not exist' do
    Conference.where(year: 2011).first || FactoryGirl.create(:conference, year: 2011)
    controller.stubs(:render)
    controller.expects(:render).with(template: 'static_pages/2011_syntax_help')

    get :show, path: 'syntax_help', year: 2011
  end

  it 'should render page if page exists' do
    page = FactoryGirl.create(:page, path: 'my_test')
    controller.stubs(:render)
    controller.expects(:render).with(:show)

    get :show, path: 'my_test', year: page.conference.year

    expect(assigns(:page)).to eq(page)
  end
end
