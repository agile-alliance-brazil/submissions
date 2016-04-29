# encoding: UTF-8
require 'spec_helper'

describe SessionTypesController, type: :controller do
  let(:conference) { FactoryGirl.create(:conference) }
  let(:session_type) { FactoryGirl.build(:session_type, conference: conference) }
  let(:another_conf_type) { FactoryGirl.create(:session_type, conference: FactoryGirl.create(:conference)) }
  let(:admin) { FactoryGirl.create(:user).tap{|u| u.add_role('admin'); u.save} }

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
      post :create, year: conference.year, session_type: {
        translated_contents_attributes: session_type.translated_contents.inject({}) { |acc, s|
          acc[acc.size.to_s]= s.attributes; acc
          }
        }, locale: conference.supported_languages.first

      new_session_type = SessionType.last
      expect(new_session_type.translated_contents.map(&:language)).to eq(session_type.translated_contents.map(&:language))
      expect(new_session_type.translated_contents.map(&:title)).to eq(session_type.translated_contents.map(&:title))
      expect(new_session_type.translated_contents.map(&:content)).to eq(session_type.translated_contents.map(&:content))
    end

    context 'with html format' do
      it 'should redirect to session types index' do
        post :create, year: conference.year, session_type: {
          translated_contents_attributes: session_type.translated_contents.inject({}) { |acc, s|
              acc[acc.size.to_s]= s.attributes; acc
            }
          }, locale: conference.supported_languages.first

        expect(subject).to redirect_to(conference_session_types_path(conference))
      end
    end

    context 'incomplete data' do
      it 'should flash a failure message' do
        post :create, year: conference.year, session_type: { 
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        post :create, year: conference.year, session_type: { 
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt' }
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
        conference.tap{|c| c.visible=false; c.save }
      end

      it 'should allow for valid duration change' do
        language = conference.supported_languages.first

        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: ['10', '25'] }

        expect(session_type.reload.valid_durations).to eq(['10', '25'])
      end
    end

    context 'with visible conference' do
      it 'should not allow for valid duration change' do
        language = conference.supported_languages.first

        patch :update, year: conference.year, id: session_type.id, session_type: {
          valid_durations: ['10', '25'] }

        expect(session_type.reload.valid_durations).to eq([50])
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
            '0' => { id: session_type.translated_contents.first.id, language: 'pt' }
          }
        }

        expect(flash[:error]).to be_present
      end

      it 'should render conference edit page' do
        patch :update, year: conference.year, id: session_type.id, session_type: {
          translated_contents_attributes: {
            '0' => { id: session_type.translated_contents.first.id, language: 'pt' }
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
