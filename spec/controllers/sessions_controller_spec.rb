# frozen_string_literal: true

RSpec.describe SessionsController, type: :controller do
  let(:author) { FactoryBot.create(:author) }
  let(:conference) { FactoryBot.create(:conference) }

  context 'disabled authorizations' do
    render_views

    it_should_require_login_for_actions :index, :show, :new, :create, :edit, :update

    let(:audience_level) { FactoryBot.create(:audience_level, conference: conference) }
    let(:session_type) { FactoryBot.create(:session_type, conference: conference) }
    let(:track) { FactoryBot.create(:track, conference: conference) }
    let(:session) { FactoryBot.create(:session, conference: conference, author: author) }
    let(:valid_params) do
      {
        title: 'Testing',
        summary: 'Testing a summary',
        description: 'Testing a description that is long.' * 50,
        mechanics: 'Testing medium mechanics' * 10,
        benefits: 'Testing medium benefits' * 10,
        target_audience: 'Everybody!',
        prerequisites: 'None!',
        audience_level_id: audience_level.id,
        track_id: track.id,
        session_type_id: session_type.id,
        duration_mins: session_type.valid_durations.first.to_s,
        experience: 'A lot!',
        keyword_list: 'tags.tdd,tags.tecniques',
        language: 'pt-BR'
      }
    end
    before(:each) do
      # Need session types to suggest durations in the form
      @session_types = [session_type]
      ActsAsTaggableOn::Tag.create(name: 'tags.tdd')
      ActsAsTaggableOn::Tag.create(name: 'tags.tecniques')

      sign_in author
      disable_authorization
      EmailNotifications.stubs(:session_submitted).returns(stub(deliver_now: true))
    end

    context 'show action' do
      it 'should render show template with comment' do
        get :show, year: conference.year, id: session.id

        expect(response).to render_template(:show)
        expect(assigns(:comment).user).to eq(author)
        expect(assigns(:comment).commentable_id).to eq(session.id)
      end

      it 'should display flash news if session from previous conference' do
        old_conference = FactoryBot.create(:conference, year: 1)
        old_session = FactoryBot.create(:session,
                                        session_type: FactoryBot.create(:session_type, conference: old_conference),
                                        audience_level: FactoryBot.create(:audience_level, conference: old_conference),
                                        track: FactoryBot.create(:track, conference: old_conference),
                                        conference: old_conference)

        get :show, year: conference.year, id: old_session.id

        message = I18n.t('flash.news.session_different_conference',
                         conference_name: old_conference.name,
                         current_conference_name: conference.name,
                         locale: author.default_locale)
        expect(flash[:news]).to eq(message)
      end
    end

    context 'new action' do
      before do
        @tracks = [track]
        @audience_levels = [audience_level]
      end
      it 'should render new template' do
        get :new, year: conference.year

        expect(response).to render_template(:new)
      end

      it 'should only assign tracks for current conference' do
        get :new, year: conference.year

        expect(assigns(:tracks)).to eq(@tracks)
      end

      it 'should only assign audience levels for current conference' do
        get :new, year: conference.year

        expect(assigns(:audience_levels)).to eq(@audience_levels)
      end

      it 'should only assign session types for current conference' do
        get :new, year: conference.year

        expect(assigns(:session_types)).to eq(@session_types)
      end
    end

    context 'create action' do
      it 'should render new template when model is invalid' do
        post :create, year: conference.year, session: { title: 'Test' }

        expect(response).to render_template(:new)
      end

      it 'should redirect when model is valid' do
        post :create, year: conference.year, session: valid_params

        expect(response).to redirect_to(session_url(conference, assigns(:session)))
      end

      it 'should ignore unknown tags' do
        post :create, year: conference.year, session: valid_params.merge(keyword_list: 'tags.tdd,tags.tecniques,unknown')

        expect(assigns(:session).keyword_list).to eq(['tags.tdd', 'tags.tecniques'])
      end

      it 'should send an email when model is valid' do
        EmailNotifications.expects(:session_submitted).returns(mock(deliver_now: true))

        post :create, year: conference.year, session: valid_params
      end
    end

    context 'edit action' do
      it 'should render edit template' do
        get :edit, year: conference.year, id: session.id

        expect(response).to render_template(:edit)
      end

      it 'should only assign tracks for current conference' do
        get :edit, year: conference.year, id: session.id

        expect(assigns(:tracks) - conference.tracks).to be_empty
      end

      it 'should only assign audience levels for current conference' do
        get :edit, year: conference.year, id: session.id

        expect(assigns(:audience_levels) - conference.audience_levels).to be_empty
      end

      it 'should only assign session types for current conference' do
        get :edit, year: conference.year, id: session.id

        expect(assigns(:session_types) - conference.session_types).to be_empty
      end
    end

    context 'update action' do
      it 'should render edit template when model is invalid' do
        patch :update, year: conference.year, id: session.id, session: { title: nil }

        expect(response).to render_template(:edit)
      end

      it 'should redirect when model is valid' do
        patch :update, year: conference.year, id: session.id, session: valid_params

        expect(response).to redirect_to(session_path(conference, assigns(:session)))
      end

      it 'should ignore unknown tags' do
        post :create, year: conference.year, session: valid_params.merge(keyword_list: 'tags.tdd,tags.tecniques,unknown')

        expect(assigns(:session).keyword_list).to eq(['tags.tdd', 'tags.tecniques'])
      end

      it 'should maintain author and second_author if editing as second_author' do
        other_author = FactoryBot.create(:author)
        session.author = other_author
        session.second_author = author
        session.save(validate: false)

        patch :update, year: conference.year, id: session.id, session: valid_params

        expect(session.reload.author).to eq(other_author)
        expect(session.second_author).to eq(author)
      end
    end

    context 'cancel action' do
      it 'should cancel and redirect to organizer sessions' do
        delete :cancel, year: conference.year, id: session.id

        expect(response).to redirect_to(organizer_sessions_path(conference))
      end

      it 'should redirect to organizer sessions with error' do
        session.cancel

        delete :cancel, year: conference.year, id: session.id

        expect(response).to redirect_to(organizer_sessions_path(conference))

        error_message = I18n.t('flash.session.cancel.failure',
                               locale: author.default_locale)
        expect(flash[:error]).to eq(error_message)
      end
    end
  end

  context 'enabled authorizations' do
    context 'unauthenticated' do
      describe 'GET #index' do
        context 'with valid sessions' do
          before { get :index, year: 1 }
          it { is_expected.to redirect_to new_user_session_path }
        end
      end
    end

    context 'authenticated as normal user' do
      let(:user) { FactoryBot.create :user }
      before { sign_in user }

      describe 'GET #index' do
        context 'with valid sessions' do
          let(:conference) { FactoryBot.create(:conference) }
          let(:other_conference) { FactoryBot.create(:conference) }

          let!(:track) { FactoryBot.create :track, conference: conference, title: 'zzz' }
          let!(:other_track) { FactoryBot.create :track, conference: conference, title: 'aaa' }
          let!(:out_track) { FactoryBot.create :track, title: 'out', conference: other_conference }

          let!(:type) { FactoryBot.create :session_type, conference: conference, title: 'zzz' }
          let!(:other_type) { FactoryBot.create :session_type, conference: conference, title: 'aaa' }
          let!(:out_type) { FactoryBot.create :session_type, title: 'out', conference: other_conference }

          let!(:session) { FactoryBot.create(:session, conference: conference, author: author, track: track, session_type: type) }
          let!(:other_session) { FactoryBot.create(:session, conference: conference, author: author, track: other_track, session_type: other_type) }
          let!(:cancelled_session) { FactoryBot.create :session_cancelled }
          let!(:out_session) { FactoryBot.create(:session, conference: other_conference, author: author, track: out_track, session_type: out_type) }

          before { get :index, year: conference.year }

          it 'assigns the instance variables and renders the template' do
            expect(assigns(:conference)).to eq conference
            expect(assigns(:sessions)).to eq [other_session, session]
            expect(assigns(:tracks).to_a).to eq [other_track, track]
            expect(assigns(:session_types).to_a).to match_array [other_type, type]
            expect(response).to render_template(:index)
          end
        end

        context 'with no sessions' do
          before { get :index, year: conference.year }
          it { expect(assigns(:sessions)).to eq [] }
        end
      end
    end
  end
end
