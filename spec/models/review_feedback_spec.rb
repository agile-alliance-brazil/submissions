# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe ReviewFeedback, type: :model do
  context 'validations' do
    it { should validate_presence_of :conference }
    it { should validate_presence_of :author }

    should_validate_existence_of :conference, :author

    context 'review evaluations' do
      before(:each) do
        session = FactoryGirl.create(:session)
        session.reviewing
        @review = FactoryGirl.create(:final_review, session: session)
        FactoryGirl.create(:review_decision, session: session, published: true)

        @author = session.author
        @conference = session.conference
      end

      it 'should validate a review evaluation per review' do
        feedback = ReviewFeedback.new(author: @author, conference: @conference)

        expect(feedback).to_not be_valid
        expect(feedback.errors[:review_evaluations]).to include(I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
      end

      it 'should validate review evaluation matches review' do
        feedback = ReviewFeedback.new(author: @author, conference: @conference)
        feedback.review_evaluations.build(
          review_feedback: feedback,
          review: FactoryGirl.create(:final_review),
          helpful_review: false,
          comments: ''
        )

        expect(feedback).to_not be_valid
        expect(feedback.errors[:review_evaluations]).to include(I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
      end

      it 'should accept matching evaluation and review' do
        feedback = ReviewFeedback.new(author: @author, conference: @conference)
        evaluation = ReviewEvaluation.new(
          review_feedback: feedback,
          review: @review,
          helpful_review: false,
          comments: ''
        )
        feedback.review_evaluations << evaluation

        expect(evaluation).to be_valid
        expect(feedback).to be_valid
      end
    end
  end

  context 'associations' do
    it { should belong_to :conference }
    it { should belong_to :author }
    it { should have_many :review_evaluations }
  end
end
