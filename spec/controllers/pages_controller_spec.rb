# frozen_string_literal: true

require 'spec_helper'

describe PagesController, type: :controller do
  let(:conference) { FactoryBot.create(:conference) }
  let(:admin) do
    FactoryBot.create(:user).tap do |u|
      u.add_role('admin')
      u.save
    end
  end

  context 'show' do
    it 'routes to guidelines page' do
      expect(get: '/2010/guidelines').to route_to(controller: 'pages',
                                                  action: 'show',
                                                  path: 'guidelines',
                                                  year: '2010')
    end

    context 'rendering view' do
      render_views

      it 'does not double escape html content' do
        page = FactoryBot.create(:page)

        get :show, path: page.path, year: page.conference.year

        expect(response.body).to(
          match(%r{<p>This is a page under path <ins>#{page.path}</ins> for conference \
<strong>#{page.conference.name}</strong> that renders with <code>Textile</code>.</p>}m)
        )
      end
    end

    it 'renders page if page exists' do
      page = FactoryBot.create(:page)
      controller.stubs(:render)
      controller.expects(:render).with(:show)

      get :show, path: page.path, year: page.conference.year

      expect(assigns(:page)).to eq(page)
    end

    it 'renders static resource if page does not exist' do
      Conference.where(year: 2011).first || FactoryBot.create(:conference, year: 2011)
      controller.stubs(:render)
      controller.expects(:render).with(template: 'static_pages/2011_syntax_help')

      get :show, path: 'syntax_help', year: 2011
    end

    it 'renders 404 if static page does not exist' do
      Conference.where(year: 5000).first || FactoryBot.create(:conference, year: 5000)

      get :show, path: 'syntax_help', year: 5000

      expect(response.status).to eq(404)
    end
  end

  context 'create action' do
    let(:page) { FactoryBot.build(:page, conference: conference) }

    before do
      sign_in admin
      disable_authorization
    end

    it 'saves new page with content' do
      attributes = page.translated_contents.each_with_object({}) do |tc, acc|
        acc[acc.size.to_s] = tc.attributes
        acc
      end
      post :create, year: page.conference.year, page: {
        path: page.path,
        show_in_menu: '1',
        translated_contents_attributes: attributes
      }, locale: conference.supported_languages.first

      expect(assigns[:page].path).to eq(page.path)
      expect(assigns[:page]).to be_show_in_menu
      expect(assigns[:page].translated_contents.map(&:language)).to eq(page.translated_contents.map(&:language))
      expect(assigns[:page].translated_contents.map(&:title)).to eq(page.translated_contents.map(&:title))
      expect(assigns[:page].translated_contents.map(&:content)).to eq(page.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'redirects to show page' do
        attributes = page.translated_contents.each_with_object({}) do |tc, acc|
          acc[acc.size.to_s] = tc.attributes
          acc
        end
        post :create, year: page.conference.year, page: {
          path: page.path,
          translated_contents_attributes: attributes
        }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_page_path(page.conference, assigns[:page].id))
      end
    end

    context 'incomplete data' do
      it 'flashes a failure message' do
        post :create, year: page.conference.year, page: { path: page.path }

        expect(flash[:error]).to be_present
      end
      it 'renders conference edit page' do
        post :create, year: page.conference.year, page: { path: page.path }

        expect(assigns(:conference).id).to eq(page.conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).not_to be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).not_to be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).not_to be_empty
        expect(assigns(:new_page).path).to eq(page.path)
        expect(assigns(:new_page).translated_contents).not_to be_empty
      end
    end
  end

  context 'update' do
    let(:page) { FactoryBot.create(:page, conference: conference) }
    let(:new_content) { '*New* content!' }

    before do
      sign_in admin
      disable_authorization
    end

    it 'changes content' do
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
      expect(page).to be_show_in_menu
    end

    context 'with html format' do
      it 'redirects to show page' do
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
      it 'flashes a failure message' do
        patch :update, year: page.conference.year, id: page.id, page: {
          translated_contents_attributes: {
            '0' => { id: page.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end
      it 'renders conference edit page' do
        patch :update, year: page.conference.year, id: page.id, page: {
          translated_contents_attributes: {
            '0' => { id: page.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(assigns(:conference).id).to eq(page.conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).not_to be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).not_to be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).not_to be_empty
        expect(assigns(:new_page).path).to eq(page.path)
        expect(assigns(:new_page).translated_contents).not_to be_empty
      end
    end
  end
end
