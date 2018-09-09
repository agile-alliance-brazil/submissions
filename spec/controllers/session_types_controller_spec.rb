# frozen_string_literal: true

require 'spec_helper'

describe SessionTypesController, type: :controller do
  let(:conference) { FactoryBot.create(:conference) }
  let(:session_type) { FactoryBot.build(:session_type, conference: conference) }
  let(:another_conf_type) { FactoryBot.create(:session_type, conference: FactoryBot.create(:conference)) }
  let(:admin) do
    FactoryBot.create(:user).tap do |u|
      u.add_role('admin')
      u.save
    end
  end

  render_views

  before do
    Conference.stubs(:current).returns(conference)
  end

  context 'index action' do
    before { session_type.save }

    it 'renders index template' do
      get :index

      expect(response).to render_template(:index)
    end

    it 'assigns session types for current conference' do
      get :index

      expect(assigns(:session_types)).to eq([session_type])
    end
  end

  context 'create action' do
    before do
      sign_in admin
      disable_authorization
    end

    it 'saves new session type with content' do
      attributes = session_type.translated_contents.each_with_object({}) do |s, acc|
        acc[acc.size.to_s] = s.attributes
        acc
      end
      post :create, year: conference.year, session_type: {
        valid_durations: ['50'],
        needs_audience_limit: '1',
        needs_mechanics: '0',
        translated_contents_attributes: attributes
      }, locale: conference.supported_languages.first

      new_session_type = SessionType.last
      expect(new_session_type.valid_durations).to eq([50])
      expect(new_session_type).to be_needs_audience_limit
      expect(new_session_type).not_to be_needs_mechanics
      expect(new_session_type.translated_contents.map(&:language)).to eq(session_type.translated_contents.map(&:language))
      expect(new_session_type.translated_contents.map(&:title)).to eq(session_type.translated_contents.map(&:title))
      expect(new_session_type.translated_contents.map(&:content)).to eq(session_type.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'redirects to session types index' do
        attributes = session_type.translated_contents.each_with_object({}) do |s, acc|
          acc[acc.size.to_s] = s.attributes
          acc
        end
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: attributes
        }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_session_types_path(conference))
      end
    end

    context 'incomplete data' do
      it 'flashes a failure message' do
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'renders conference edit page' do
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(assigns(:conference).id).to eq(conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).not_to be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).not_to be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).not_to be_empty
        expect(assigns(:new_page)).to be_a(Page)
        expect(assigns(:new_page).translated_contents).not_to be_empty
      end
    end
  end

  context 'update' do
    let(:new_content) { '*New* content!' }

    before do
      sign_in admin
      disable_authorization

      session_type.save
    end

    it 'changes content' do
      language = conference.supported_languages.first

      patch :update, year: conference.year, id: session_type.id, session_type: {
        translated_contents_attributes: {
          '0' => { id: session_type.translated_contents.first.id.to_s,
                   content: new_content }
        }
      }, locale: language

      I18n.with_locale(language) do
        expect(session_type.reload.description).to eq(new_content)
      end
    end

    context 'while conference is not visible' do
      before do
        conference.tap do |c|
          c.visible = false
          c.save
        end
      end

      it 'allows for valid duration change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: %w[10 25]
        }

        expect(session_type.reload.valid_durations).to eq([10, 25])
      end

      it 'allows for need mechanics change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_mechanics: '1'
        }

        expect(session_type.reload).to be_needs_mechanics
      end

      it 'allows for need audience level change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_audience_limit: '1'
        }

        expect(session_type.reload).to be_needs_audience_limit
      end
    end

    context 'with visible conference' do
      it 'does not allow for valid duration change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: %w[10 25]
        }

        expect(session_type.reload.valid_durations).to eq([50])
      end

      it 'does not allow for need audience limit change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_audience_limit: '1'
        }

        expect(session_type.reload).not_to be_needs_audience_limit
      end

      it 'does not allow for need mechanics change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_mechanics: '1'
        }

        expect(session_type.reload).not_to be_needs_mechanics
      end
    end

    context 'with html format' do
      it 'redirects to show page' do
        language = conference.supported_languages.first

        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id.to_s,
                     content: new_content }
          }
        }, locale: language

        expect(subject).to redirect_to(conference_session_types_path(conference))
      end
    end

    context 'incomplete data' do
      it 'flashes a failure message' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'renders conference edit page' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(assigns(:conference).id).to eq(conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).not_to be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).not_to be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).not_to be_empty
        expect(assigns(:new_page)).to be_a(Page)
        expect(assigns(:new_page).translated_contents).not_to be_empty
      end
    end
  end
end
