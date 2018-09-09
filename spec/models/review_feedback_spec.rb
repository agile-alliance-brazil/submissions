# frozen_string_literal: true

require 'spec_helper'

describe ReviewFeedback, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :conference }
    it { is_expected.to validate_presence_of :author }

    should_validate_existence_of :conference, :author

    describe 'review evaluations' do
      subject(:feedback) { ReviewFeedback.new(author: author, conference: conference) }

      let(:session) { FactoryBot.build(:session).tap(&:reviewing) }
      let(:author) { session.author }
      let(:conference) { session.conference }
      let(:review) { FactoryBot.build(:final_review, session: session) }

      before do
        review.save!

        FactoryBot.create(:review_decision, session: session, published: true)
      end

      it 'validates a review evaluation per review' do
        feedback = ReviewFeedback.new(author: author, conference: conference)

        expect(feedback).not_to be_valid
        expect(feedback.errors[:review_evaluations]).to include(I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
      end

      it 'validates review evaluation matches review' do
        feedback.review_evaluations.build(review_feedback: feedback, review: FactoryBot.create(:final_review), helpful_review: false, comments: '')

        expect(feedback).not_to be_valid
        expect(feedback.errors[:review_evaluations]).to include(I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
      end

      it 'accepts matching evaluation and review' do
        evaluation = ReviewEvaluation.new(review_feedback: feedback, review: review, helpful_review: false, comments: '')
        feedback.review_evaluations << evaluation

        expect(evaluation).to be_valid
        expect(feedback).to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :conference }
    it { is_expected.to belong_to :author }
    it { is_expected.to have_many :review_evaluations }
  end
end
