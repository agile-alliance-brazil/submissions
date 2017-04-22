# encoding: UTF-8
# frozen_string_literal: true

require 'spec_helper'

describe SessionTypesController, type: :controller do
  let(:conference) { FactoryGirl.create(:conference) }
  let(:session_type) { FactoryGirl.build(:session_type, conference: conference) }
  let(:another_conf_type) { FactoryGirl.create(:session_type, conference: FactoryGirl.create(:conference)) }
  let(:admin) do
    FactoryGirl.create(:user).tap do |u|
      u.add_role('admin')
      u.save
    end
  end

  render_views

  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  context 'index action' do
    before(:each) { session_type.save }

    it 'should render index template' do
      get :index

      expect(response).to render_template(:index)
    end

    it 'should assign session types for current conference' do
      get :index

      expect(assigns(:session_types)).to eq([session_type])
    end
  end

  context 'create action' do
    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should save new session type with content' do
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
      expect(new_session_type.needs_audience_limit?).to be_truthy
      expect(new_session_type.needs_mechanics?).to be_falsey
      expect(new_session_type.translated_contents.map(&:language)).to eq(session_type.translated_contents.map(&:language))
      expect(new_session_type.translated_contents.map(&:title)).to eq(session_type.translated_contents.map(&:title))
      expect(new_session_type.translated_contents.map(&:content)).to eq(session_type.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'should redirect to session types index' do
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
      it 'should flash a failure message' do
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(assigns(:conference).id).to eq(conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).to_not be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).to_not be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).to_not be_empty
        expect(assigns(:new_page)).to be_a(Page)
        expect(assigns(:new_page).translated_contents).to_not be_empty
      end
    end
  end

  context 'update' do
    let(:new_content) { '*New* content!' }

    before(:each) do
      sign_in admin
      disable_authorization

      session_type.save
    end

    it 'should change content' do
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

      it 'should allow for valid duration change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: %w[10 25]
        }

        expect(session_type.reload.valid_durations).to eq([10, 25])
      end

      it 'should allow for need mechanics change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_mechanics: '1'
        }

        expect(session_type.reload.needs_mechanics?).to be_truthy
      end

      it 'should allow for need audience level change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_audience_limit: '1'
        }

        expect(session_type.reload.needs_audience_limit?).to be_truthy
      end
    end

    context 'with visible conference' do
      it 'should not allow for valid duration change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: %w[10 25]
        }

        expect(session_type.reload.valid_durations).to eq([50])
      end

      it 'should not allow for need audience limit change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_audience_limit: '1'
        }

        expect(session_type.reload.needs_audience_limit?).to be_falsey
      end

      it 'should not allow for need mechanics change' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          needs_mechanics: '1'
        }

        expect(session_type.reload.needs_mechanics?).to be_falsey
      end
    end

    context 'with html format' do
      it 'should redirect to show page' do
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
      it 'should flash a failure message' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(assigns(:conference).id).to eq(conference.id)
        expect(assigns(:new_track)).to be_a(Track)
        expect(assigns(:new_track).translated_contents).to_not be_empty
        expect(assigns(:new_audience_level)).to be_a(AudienceLevel)
        expect(assigns(:new_audience_level).translated_contents).to_not be_empty
        expect(assigns(:new_session_type)).to be_a(SessionType)
        expect(assigns(:new_session_type).translated_contents).to_not be_empty
        expect(assigns(:new_page)).to be_a(Page)
        expect(assigns(:new_page).translated_contents).to_not be_empty
      end
    end
  end
end
