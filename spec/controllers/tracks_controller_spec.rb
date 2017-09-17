# frozen_string_literal: true

require 'spec_helper'

describe TracksController, type: :controller do
  render_views

  let(:conference) { FactoryGirl.create(:conference) }
  let(:admin) do
    FactoryGirl.create(:user).tap do |u|
      u.add_role('admin')
      u.save
    end
  end

  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  context 'index action' do
    let(:track) { FactoryGirl.create(:track, conference: conference) }

    it 'should render index template' do
      get :index, year: track.conference.year

      expect(response).to render_template(:index)
    end

    it 'should assign tracks for current conference' do
      get :index, year: track.conference.year

      expect(assigns(:tracks)).to eq([track])
    end
  end

  context 'create action' do
    let(:track) { FactoryGirl.build(:track, conference: conference) }

    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should save new track with content' do
      attributes = track.translated_contents.each_with_object({}) do |t, acc|
        acc[acc.size.to_s] = t.attributes
        acc
      end
      post :create, year: conference.year, track: {
        translated_contents_attributes: attributes
      }, locale: conference.supported_languages.first

      new_track = Track.last
      expect(new_track.translated_contents.map(&:language)).to eq(track.translated_contents.map(&:language))
      expect(new_track.translated_contents.map(&:title)).to eq(track.translated_contents.map(&:title))
      expect(new_track.translated_contents.map(&:content)).to eq(track.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'should redirect to track index' do
        attributes = track.translated_contents.each_with_object({}) do |t, acc|
          acc[acc.size.to_s] = t.attributes
          acc
        end
        post :create, year: conference.year, track: {
          translated_contents_attributes: attributes
        }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_tracks_path(conference))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        post :create, year: conference.year, track: {
          translated_contents_attributes: {
            '0' => { id: track.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        post :create, year: conference.year, track: {
          translated_contents_attributes: {
            '0' => { id: track.translated_contents.first.id, language: 'pt-BR' }
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
    let(:track) { FactoryGirl.create(:track, conference: conference) }
    let(:new_content) { '*New* content!' }

    before(:each) do
      sign_in admin
      disable_authorization
    end

    it 'should change content' do
      language = conference.supported_languages.first

      patch :update, year: conference.year, id: track.id, track: {
        translated_contents_attributes: {
          '0' => { id: track.translated_contents.first.id.to_s,
                   content: new_content }
        }
      }, locale: language

      I18n.with_locale(language) do
        expect(track.reload.description).to eq(new_content)
      end
    end

    context 'with html format' do
      it 'should redirect to show page' do
        language = conference.supported_languages.first

        patch :update, year: conference.year, id: track.id, track: {
          translated_contents_attributes: {
            '0' => { id: track.translated_contents.first.id.to_s,
                     content: new_content }
          }
        }, locale: language

        expect(subject).to redirect_to(conference_tracks_path(conference))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        patch :update, year: conference.year, id: track.id, track: {
          translated_contents_attributes: {
            '0' => { id: track.translated_contents.first.id, language: 'pt-BR' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        patch :update, year: conference.year, id: track.id, track: {
          translated_contents_attributes: {
            '0' => { id: track.translated_contents.first.id, language: 'pt-BR' }
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
