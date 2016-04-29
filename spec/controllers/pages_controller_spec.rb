# encoding: UTF-8
require 'spec_helper'

describe PagesController, type: :controller do
  let(:conference) { FactoryGirl.create(:conference) }
  let(:admin) { FactoryGirl.create(:user).tap{|u| u.add_role('admin'); u.save} }

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

  context 'create action' do
    let(:page) { FactoryGirl.build(:page, conference: conference) }
    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should save new page with content' do
      post :create, year: page.conference.year, page: {
        path: page.path,
        show_in_menu: '1',
        translated_contents_attributes: page.translated_contents.inject({}) { |acc, tc|
          acc[acc.size.to_s]= tc.attributes; acc
          }
        }, locale: conference.supported_languages.first

      expect(assigns[:page].path).to eq(page.path)
      expect(assigns[:page].show_in_menu?).to be_truthy
      expect(assigns[:page].translated_contents.map(&:language)).to eq(page.translated_contents.map(&:language))
      expect(assigns[:page].translated_contents.map(&:title)).to eq(page.translated_contents.map(&:title))
      expect(assigns[:page].translated_contents.map(&:content)).to eq(page.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'should redirect to show page' do
        post :create, year: page.conference.year, page: {
          path: page.path,
          translated_contents_attributes: page.translated_contents.inject({}) { |acc, tc|
            acc[acc.size.to_s]= tc.attributes; acc
            }
          }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_page_path(page.conference, assigns[:page].id))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        post :create, year: page.conference.year, page: { path: page.path }

        expect(flash[:error]).to be_present
      end
      it 'should render conference edit page' do
        post :create, year: page.conference.year, page: { path: page.path }

        expect(assigns(:conference).id).to eq(page.conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).to_not be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).to_not be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).to_not be_empty
        expect(assigns(:new_page).path).to eq(page.path)
        expect(assigns(:new_page).translated_contents).to_not be_empty
      end
    end
  end

  context 'update' do
    let(:page) { FactoryGirl.create(:page, conference: conference) }
    let(:new_content) { '*New* content!' }

    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should change content' do
      language = conference.supported_languages.first

      patch :update, year: page.conference.year, id: page.id, page: {
        show_in_menu: '1',
        translated_contents_attributes: {
          '0' => { id: page.translated_contents.first.id.to_s,
            content: new_content }
          }
        }, locale: language

      I18n.with_locale(language) do
        expect(page.reload.content).to eq(new_content)
      end
      expect(page.show_in_menu?).to be_truthy
    end

    context 'with html format' do
      it 'should redirect to show page' do
        language = conference.supported_languages.first

        patch :update, year: page.conference.year, id: page.id, page: {
          translated_contents_attributes: {
            '0' => { id: page.translated_contents.first.id.to_s,
              content: new_content }
            }
          }, locale: language

        expect(subject).to redirect_to(conference_page_path(page.conference, page))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        patch :update, year: page.conference.year, id: page.id, page: {
          translated_contents_attributes: {
            '0' => { id: page.translated_contents.first.id, language: 'pt' }
          }
        }

        expect(flash[:error]).to be_present
      end
      it 'should render conference edit page' do
        patch :update, year: page.conference.year, id: page.id, page: {
          translated_contents_attributes: {
            '0' => { id: page.translated_contents.first.id, language: 'pt' }
          }
        }

        expect(assigns(:conference).id).to eq(page.conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).to_not be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).to_not be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).to_not be_empty
        expect(assigns(:new_page).path).to eq(page.path)
        expect(assigns(:new_page).translated_contents).to_not be_empty
      end
    end
  end
end
