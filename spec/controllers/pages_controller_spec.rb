# encoding: UTF-8
require 'spec_helper'

describe PagesController, type: :controller do
  context 'show' do
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
      page = FactoryGirl.create(:page)
      controller.stubs(:render)
      controller.expects(:render).with(:show)

      get :show, path: page.path, year: page.conference.year

      expect(assigns(:page)).to eq(page)
    end
  end

  context 'update' do
    let(:conference) { FactoryGirl.create(:conference) }
    let(:page) { FactoryGirl.create(:page, conference: conference) }
    let(:admin) { FactoryGirl.create(:user).tap{|u| u.add_role('admin'); u.save} }
    before(:each) do
      sign_in admin
      disable_authorization

      Conference.stubs(:current).returns(conference)
      conference.stubs(:in_early_review_phase?).returns(false)
    end

    it 'should change content' do
      new_content = '*New* content!'

      patch :update, year: page.conference.year, id: page.id, page: {content: new_content}

      expect(page.reload.content).to eq(new_content)
    end

    context 'with html format' do
      it 'should redirect to show page' do
        new_content = '*New* content!'

        patch :update, year: page.conference.year, id: page.id, page: {content: new_content}

        expect(subject).to redirect_to(conference_page_path(page.conference, page.path))
      end
    end
  end
end
