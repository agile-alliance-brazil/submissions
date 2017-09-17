# frozen_string_literal: true

require 'spec_helper'

describe ReviewsController, type: :controller do
  let(:valid_early_review_params) do
    {
      author_agile_xp_rating_id: 1,
      author_proposal_xp_rating_id: 1,
      proposal_track: true,
      proposal_level: true,
      proposal_type: true,
      proposal_duration: true,
      proposal_limit: true,
      proposal_abstract: true,
      proposal_quality_rating_id: 1,
      proposal_relevance_rating_id: 1,
      reviewer_confidence_rating_id: 1,
      comments_to_organizers: 'This is awesome!',
      comments_to_authors: "You're the best!" * 10
    }
  end

  context 'disabled authorization' do
    let(:valid_final_review_params) do
      valid_early_review_params.merge(recommendation_id: 1,
                                      justification: 'This is great!')
    end
    let(:conference) { FactoryGirl.create(:conference) }
    let(:session) { FactoryGirl.create(:session, conference: conference).tap(&:reviewing) }
    let(:reviewer) { FactoryGirl.create(:reviewer, conference: conference) }

    before(:each) do
      sign_in reviewer.user
      disable_authorization

      Conference.stubs(:current).returns(conference)
      conference.stubs(:in_early_review_phase?).returns(false)
    end

    context 'with view rendering', render_views: true do
      render_views

      describe 'collection' do
        def new_reviewer
          FactoryGirl.create(:reviewer, conference: conference)
        end

        before do
          FactoryGirl.create(:early_review, session: session, reviewer: new_reviewer.user)
          FactoryGirl.create(:final_review, session: session, reviewer: new_reviewer.user)
          FactoryGirl.create(:final_review, session: session, reviewer: new_reviewer.user)
          FactoryGirl.create(:final_review, session: session, reviewer: new_reviewer.user)
        end
        it 'index early reviews for organizer should work' do
          get :organizer, year: conference.year, session_id: session.id, type: 'early'
        end

        it 'index final reviews for organizer should work' do
          get :organizer, year: conference.year, session_id: session.id
        end

        it 'index early reviews for author should work' do
          get :index, year: conference.year, session_id: session.id, type: 'early'
        end

        it 'index final reviews for author should work' do
          get :index, year: conference.year, session_id: session.id
        end
      end

      it 'show should work for early review' do
        early_review = FactoryGirl.create(:early_review,
                                          reviewer: reviewer.user, session: session)

        get :show, year: conference.year, id: early_review.id, session_id: session.id

        expect(assigns(:review)).to_not be_nil
      end

      it 'show should work for final review' do
        final_review = FactoryGirl.create(:final_review,
                                          reviewer: reviewer.user, session: session)

        get :show, year: conference.year, id: final_review.id, session_id: session.id

        expect(assigns(:review)).to_not be_nil
      end

      it 'new should work for early review' do
        conference.expects(:in_early_review_phase?).returns(true)
        get :new, session_id: session.id
      end

      it 'show should work for final review' do
        conference.expects(:in_early_review_phase?).returns(false)
        get :new, session_id: session.id
      end
    end

    it_should_require_login_for_actions :index, :show, :new, :create

    it 'new action should set reviewer' do
      get :new, year: conference.year, session_id: session.id

      expect(assigns(:review).reviewer).to eq(reviewer.user)
    end

    it 'create action should render new template when model is invalid' do
      params = valid_early_review_params.except(:comments_to_authors)

      post :create, session_id: session.id, final_review: params

      expect(response).to render_template(:new)
    end

    it 'create action should redirect when final review is valid' do
      conference.expects(:in_early_review_phase?).returns(false)
      params = valid_final_review_params

      post :create, session_id: session.id, final_review: params

      expect(assigns(:review)).to_not be_nil
      path = session_review_path(conference, assigns(:session), assigns(:review))
      expect(response).to redirect_to(path)
    end

    it 'create action should redirect when early review is valid' do
      conference.stubs(:in_early_review_phase?).returns(true)
      params = valid_early_review_params

      post :create, session_id: session.id, early_review: params

      expect(assigns(:review)).to_not be_nil
      path = session_review_path(conference, assigns(:session), assigns(:review))
      expect(response).to redirect_to(path)
    end
  end

  context 'enabled authorization' do
    let(:conference) { FactoryGirl.create(:conference, call_for_papers: 5.days.ago, submissions_open: 4.days.ago, presubmissions_deadline: 3.days.ago, prereview_deadline: 1.day.from_now) }
    let(:track) { FactoryGirl.create(:track, conference: conference) }
    let(:level) { FactoryGirl.create(:audience_level, conference: conference) }
    let!(:session) { FactoryGirl.create(:session, conference: conference, track: track, audience_level: level, created_at: 4.days.ago) }
    let(:reviewer) do
      user = FactoryGirl.create :user, roles: [:reviewer]
      reviewer = FactoryGirl.build :reviewer, conference: conference, user: user
      preference = FactoryGirl.build :preference, reviewer: reviewer, track: track, audience_level: level, accepted: true
      reviewer.preferences = [preference]
      reviewer.save
      reviewer
    end

    context 'unauthenticated' do
      context 'GET #edit' do
        before { get :edit, year: conference.year, session_id: session, id: 'bar' }
        it { expect(response).to redirect_to new_user_session_path }

        context 'when the user is not the reviewer' do
          let(:other_user_review) { FactoryGirl.create :early_review, session: session }
          before do
            sign_in reviewer.user
            get :edit, year: conference.year, session_id: session.id, id: other_user_review.id
          end
          it { is_expected.to redirect_to root_path }
        end
      end
      describe 'PUT #update' do
        before { put :update, year: conference.year, session_id: session, id: 'bar' }
        it { expect(response).to redirect_to new_user_session_path }

        context 'when the user is not the reviewer' do
          let(:other_user_review) { FactoryGirl.create :early_review, session: session }
          before do
            sign_in reviewer.user
            put :update, year: conference.year, session_id: session, id: other_user_review
          end
          it { is_expected.to redirect_to root_path }
        end
      end
    end

    context 'authenticated as a reviewer' do
      let(:review) { FactoryGirl.create :early_review, reviewer: reviewer.user, session: session }

      before do
        sign_in reviewer.user
        disable_authorization
      end

      describe 'GET #edit' do
        context 'when the user is the reviewer' do
          it 'assings the instance variable and renders the template' do
            get :edit, year: conference.year, session_id: session.id, id: review.id

            expect(response).to render_template :edit
            expect(assigns(:review)).to eq review
          end
        end

        context 'with an invalid session' do
          before { get :edit, year: conference.year, session_id: 'foo', id: review.id }
          it { expect(response.status).to eq 404 }
        end

        context 'when the deadline has passed' do
          it 'redirects to root_path with the error message' do
            conference.call_for_papers = 5.days.ago
            conference.submissions_open = 4.days.ago
            conference.presubmissions_deadline = 3.days.ago
            conference.prereview_deadline = 1.day.ago
            conference.save!

            get :edit, year: conference.year, session_id: session.id, id: review.id

            expect(response).to redirect_to root_path
            expect(flash[:error]).to be_blank
            expect(flash[:alert]).to eq I18n.t('reviews.edit.errors.conference_out_of_range')
          end
        end
      end

      describe 'PUT #update' do
        context 'when the user is the reviewer' do
          before { put :update, year: conference.year, session_id: session.id, id: review.id, early_review: valid_early_review_params }
          it { is_expected.to redirect_to session_review_path(conference, session, review) }
          context 'flash' do
            subject { flash[:notice] }
            it { is_expected.to eq(I18n.t('reviews.update.success')) }
          end
          context 'updated review' do
            subject { review.reload }
            it { expect(subject.author_agile_xp_rating_id).to eq valid_early_review_params[:author_agile_xp_rating_id] }
            it { expect(subject.author_proposal_xp_rating_id).to eq valid_early_review_params[:author_proposal_xp_rating_id] }
            it { expect(subject.proposal_track).to eq valid_early_review_params[:proposal_track] }
            it { expect(subject.proposal_level).to eq valid_early_review_params[:proposal_level] }
            it { expect(subject.proposal_type).to eq valid_early_review_params[:proposal_type] }
            it { expect(subject.proposal_limit).to eq valid_early_review_params[:proposal_limit] }
            it { expect(subject.proposal_duration).to eq valid_early_review_params[:proposal_duration] }
            it { expect(subject.proposal_abstract).to eq valid_early_review_params[:proposal_abstract] }
            it { expect(subject.proposal_quality_rating_id).to eq valid_early_review_params[:proposal_quality_rating_id] }
            it { expect(subject.proposal_relevance_rating_id).to eq valid_early_review_params[:proposal_relevance_rating_id] }
            it { expect(subject.reviewer_confidence_rating_id).to eq valid_early_review_params[:reviewer_confidence_rating_id] }
            it { expect(subject.comments_to_organizers).to eq valid_early_review_params[:comments_to_organizers] }
            it { expect(subject.comments_to_authors).to eq valid_early_review_params[:comments_to_authors] }
          end
        end

        context 'when the parameters are invalid' do
          before do
            conference.prereview_deadline = 1.day.from_now
            conference.submissions_deadline = 2.days.from_now
            conference.voting_deadline = 3.days.from_now
            conference.save!
          end
          it 'renders the template again with errors and alert message' do
            put :update,
                year: conference.year,
                session_id: session.id,
                id: review.id,
                early_review: { author_agile_xp_rating_id: nil, proposal_quality_rating_id: nil }

            expected_flash = "#{Review.human_attribute_name(:author_agile_xp_rating_id)}, #{Review.human_attribute_name(:proposal_quality_rating_id)}"
            expect(flash[:alert]).to eq I18n.t('errors.messages.invalid_form_data', value: expected_flash)
            expect(response).to render_template :edit
          end
        end
      end
    end
  end
end
