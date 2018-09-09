# frozen_string_literal: true

require 'spec_helper'

describe ReviewEvaluation, type: :model do
  describe 'validations' do
    subject(:evaluation) { ReviewEvaluation.new(review: review, review_feedback: review_feedback) }

    let(:session) { FactoryBot.build(:session) }
    let(:review) { FactoryBot.build(:final_review, session: session) }
    let(:review_feedback) { FactoryBot.build(:review_feedback, author: session.author, conference: session.conference) }

    it { is_expected.to validate_presence_of :review }
    should_validate_existence_of :review

    it 'validates conference of feedback matches the one in review' do
      review_feedback.conference = FactoryBot.build(:conference)

      expect(evaluation).not_to be_valid
      expect(evaluation.errors[:review]).to include(I18n.t('activerecord.errors.models.review_evaluation.review_and_feedback_missmatch'))
    end

    it "validates author of review's session matches the one on feedback" do
      review_feedback.author = FactoryBot.build(:author)

      expect(evaluation).not_to be_valid
      expect(evaluation.errors[:review]).to include(I18n.t('activerecord.errors.models.review_evaluation.review_and_feedback_missmatch'))
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :review }
    it { is_expected.to belong_to :review_feedback }
  end
end
