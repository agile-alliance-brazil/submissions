# frozen_string_literal: true

require 'spec_helper'

describe ReviewFeedbacksController, type: :controller do
  it_should_require_login_for_actions :new, :create, :show

  before :each do
    @conference = FactoryGirl.create(:conference)
    @author = FactoryGirl.create(:author)
    Conference.stubs(:current).returns(@conference)
    @sessions = (1..2).map { |_n| FactoryGirl.create(:session, author: @author, conference: @conference) }
    @reviews = @sessions.map do |session|
      session_reviews = (1..3).map { |_n| FactoryGirl.create(:final_review, session: session) }
      session.final_reviews = session_reviews
      session_reviews
    end.flatten
    @sessions.map do |session|
      FactoryGirl.create(:review_decision, session: session, published: true)
    end
    sign_in @author
    subject.current_user.stubs(:sessions_for_conference).with(@conference).returns(@sessions)
    @sessions.stubs(:includes).returns(@sessions)
  end

  context '#new' do
    context 'once feedback was already submitted' do
      before(:each) do
        ReviewFeedback.create!(
          valid_params.merge(conference_id: @conference.id, author_id: @author.id)
        )
      end
      it 'should redirect to root' do
        get :new

        expect(response).to redirect_to(root_url(@conference))
      end
      it 'should show flash error warning feedback was already given' do
        get :new

        expect(flash[:error]).to eq(I18n.t('flash.review_feedback.new.failure'))
      end
    end
    it 'should render new template' do
      get :new

      expect(response).to render_template(:new)
    end

    it 'should assign review feedback based on current user and conference' do
      get :new

      review_feedback = assigns(:review_feedback)
      expect(review_feedback.conference).to eq(@conference)
      expect(review_feedback.author).to eq(@author)
    end

    it 'should have review evaluations for each review of that authors sessions' do
      get :new

      review_feedback = assigns(:review_feedback)
      expect(review_feedback.review_evaluations).to have(6).items
      expect(review_feedback.review_evaluations.map(&:review)).to eq(@reviews)
    end
  end

  context '#create' do
    context 'once feedback was already submitted' do
      before(:each) do
        ReviewFeedback.create!(
          valid_params.merge(conference_id: @conference.id, author_id: @author.id)
        )
      end
      it 'should redirect to root' do
        post :create, review_feedback: valid_params

        expect(response).to redirect_to(root_url(@conference))
      end
      it 'should show flash error warning feedback was already given' do
        post :create, review_feedback: valid_params

        expect(flash[:error]).to eq(I18n.t('flash.review_feedback.new.failure'))
      end
    end
    context 'success' do
      before(:each) do
        params = valid_params
        @valid_creation = -> { post :create, review_feedback: params }
      end
      it 'should flash success message' do
        @valid_creation.call

        expect(flash[:notice]).to eq(I18n.t('flash.review_feedback.create.success'))
      end

      it 'should redirect to home' do
        @valid_creation.call

        expect(response).to redirect_to(root_url(@conference))
      end

      it 'should save the review feedback' do
        expect(@valid_creation).to change { ReviewFeedback.count }.by(1)
      end
    end
    context 'on validation error' do
      it 'should flash failure message' do
        post :create, review_feedback: { general_comments: '' }

        expect(flash[:error]).to eq(I18n.t('flash.failure'))
      end

      it 'should render new template' do
        post :create, review_feedback: { general_comments: '' }

        expect(response).to render_template(:new)
      end

      it 'should assign review feedback with error' do
        post :create, review_feedback: { general_comments: '' }

        review_feedback = assigns(:review_feedback)
        expect(review_feedback.conference).to eq(@conference)
        expect(review_feedback.author).to eq(@author)
      end

      it 'should have review evaluations for each review of that authors sessions' do
        post :create, review_feedback: { general_comments: '' }

        review_feedback = assigns(:review_feedback)
        expect(review_feedback.review_evaluations).to have(6).items
        expect(review_feedback.review_evaluations.map(&:review)).to eq(@reviews)
      end

      it 'should have review evaluations for each review of that authors sessions but not more' do
        post :create, review_feedback: {
          general_comments: '',
          review_evaluations_attributes: [
            { helpful_review: true, review_id: @reviews.first.id, comments: 'Thanks!' }
          ]
        }

        review_feedback = assigns(:review_feedback)
        expect(review_feedback.review_evaluations).to have(6).items
        expect(review_feedback.review_evaluations.map(&:review)).to eq(@reviews)
      end

      it 'should have errors in the feedback' do
        post :create, review_feedback: {
          general_comments: '',
          review_evaluations_attributes: [
            { helpful_review: true, review_id: @reviews.first.id, comments: 'Thanks!' }
          ]
        }

        review_feedback = assigns(:review_feedback)
        expect(review_feedback.errors[:review_evaluations]).to include(I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
      end
    end
    it 'should filter parameters' do
      feedback = ReviewFeedback.new(valid_params)

      params_with_invalids = valid_params
      params_with_invalids[:conference_id] = '1'
      params_with_invalids[:review_evaluations_attributes].first[:feedback_id] = '1'

      ReviewFeedback.expects(:new).with(
        equals(valid_params.with_indifferent_access)
      ).returns(feedback)

      post :create, review_feedback: params_with_invalids
    end
  end
  def valid_params
    {
      general_comments: '',
      review_evaluations_attributes:
        @reviews.map { |r| { helpful_review: false, review_id: r.id.to_s, comments: 'Useless' } }
    }
  end
end
