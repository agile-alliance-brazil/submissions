# encoding: UTF-8
require 'spec_helper'

describe StaticPagesController, type: :controller do
  it 'should render template from page param' do
    Conference.where(year: 2011).first || FactoryGirl.create(:conference, year: 2011)
    controller.stubs(:render)
    controller.expects(:render).with(action: '2011_syntax_help')

    get :show, page: 'syntax_help', year: 2011
  end
end
