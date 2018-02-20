# frozen_string_literal: true

require 'spec_helper'

describe AudienceLevelsController, type: :controller do
  let(:conference) { FactoryBot.create(:conference) }
  let(:other_conf_level) { FactoryBot.create(:audience_level, conference: FactoryBot.create(:conference)) }
  let(:audience) { FactoryBot.build(:audience_level, conference: conference) }
  let(:admin) do
    FactoryBot.create(:user).tap do |u|
      u.add_role('admin')
      u.save
    end
  end

  context 'index action' do
    before(:each) { audience.save }

    it 'should render index template' do
      get :index, year: conference.year

      expect(response).to render_template(:index)
    end

    it 'should assign audience levels for given conference' do
      get :index, year: conference.year

      expect(assigns(:audience_levels)).to eq([audience])
    end
  end

  context 'create action' do
    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should save new audience level with content' do
      attributes = audience.translated_contents.each_with_object({}) do |a, acc|
        acc[acc.size.to_s] = a.attributes
        acc
      end
      post :create, year: conference.year, audience_level: {
        translated_contents_attributes: attributes
      }, locale: conference.supported_languages.first

      new_audience_level = AudienceLevel.last
      expect(new_audience_level.translated_contents.map(&:language)).to eq(audience.translated_contents.map(&:language))
      expect(new_audience_level.translated_contents.map(&:title)).to eq(audience.translated_contents.map(&:title))
      expect(new_audience_level.translated_contents.map(&:content)).to eq(audience.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'should redirect to audience levels index' do
        attributes = audience.translated_contents.each_with_object({}) do |a, acc|
          acc[acc.size.to_s] = a.attributes
          acc
        end
        post :create, year: conference.year, audience_level: {
          translated_contents_attributes: attributes
        }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_audience_levels_path(conference))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        post :create, year: conference.year, audience_level: {
          translated_contents_attributes: {
            '0' => { id: audience.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        post :create, year: conference.year, audience_level: {
          translated_contents_attributes: {
            '0' => { id: audience.translated_contents.first.id, language: 'pt-BR' }
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

      audience.save
    end

    it 'should change content' do
      language = conference.supported_languages.first

      patch :update, year: conference.year, id: audience.id, audience_level: {
        translated_contents_attributes: {
          '0' => { id: audience.translated_contents.first.id.to_s,
                   content: new_content }
        }
      }, locale: language

      I18n.with_locale(language) do
        expect(audience.reload.description).to eq(new_content)
      end
    end

    context 'with html format' do
      it 'should redirect to show page' do
        language = conference.supported_languages.first

        patch :update, year: conference.year, id: audience.id, audience_level: {
          translated_contents_attributes: {
            '0' => { id: audience.translated_contents.first.id.to_s,
                     content: new_content }
          }
        }, locale: language

        expect(subject).to redirect_to(conference_audience_levels_path(conference))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        patch :update, year: conference.year, id: audience.id, audience_level: {
          translated_contents_attributes: {
            '0' => { id: audience.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        patch :update, year: conference.year, id: audience.id, audience_level: {
          translated_contents_attributes: {
            '0' => { id: audience.translated_contents.first.id, language: 'pt-BR' }
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
