# frozen_string_literal: true

require 'spec_helper'

describe FinalReview, type: :model do
  it_should_trim_attributes FinalReview, :comments_to_organizers, :comments_to_authors, :justification

  describe 'associations' do
    it { is_expected.to belong_to :reviewer }
    it { is_expected.to belong_to :session }
    it { is_expected.to belong_to :recommendation }

    it { is_expected.to belong_to :author_agile_xp_rating }
    it { is_expected.to belong_to :author_proposal_xp_rating }
    it { is_expected.to belong_to :proposal_quality_rating }
    it { is_expected.to belong_to :proposal_relevance_rating }
    it { is_expected.to belong_to :reviewer_confidence_rating }

    it { is_expected.to have_many :review_evaluations }
  end

  it "determines if it's strong accept" do
    strong = FactoryBot.build(:recommendation, name: 'strong_accept')
    review = FactoryBot.build(:final_review)
    expect(review).not_to be_strong_accept
    review.recommendation = strong
    expect(review).to be_strong_accept
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :author_agile_xp_rating_id }
    it { is_expected.to validate_presence_of :author_proposal_xp_rating_id }

    it { is_expected.to validate_presence_of :proposal_quality_rating_id }
    it { is_expected.to validate_presence_of :proposal_relevance_rating_id }

    it { is_expected.to validate_presence_of :recommendation_id }

    it { is_expected.to validate_presence_of :reviewer_confidence_rating_id }

    it { is_expected.to validate_presence_of :reviewer_id }
    it { is_expected.to validate_presence_of :session_id }

    it { is_expected.to validate_length_of(:comments_to_authors).is_at_least(150) }

    describe 'uniqueness' do
      before { FactoryBot.create(:final_review) }

      it { is_expected.to validate_uniqueness_of(:reviewer_id).scoped_to(:session_id, :type) }
    end

    describe 'strong acceptance' do
      subject(:review) { FactoryBot.build(:final_review) }

      before { review.recommendation.name = 'strong_accept' }

      it 'is valid with justification' do
        review.justification = 'I want to justify that the session rules!'
        expect(review).to be_valid
      end

      it 'is valid without justification' do
        review.justification = nil
        expect(review).to be_valid
        review.justification = ''
        expect(review).to be_valid
      end

      it { is_expected.to be_strong_accept }
    end

    describe 'weak acceptance' do
      subject(:review) { FactoryBot.build(:final_review) }

      before { review.recommendation.name = 'weak_accept' }

      it 'is valid with justification' do
        review.justification = 'I want to justify that the session is ok.'
        expect(review).to be_valid
      end

      it 'is invalid without justification' do
        review.justification = nil
        expect(review).not_to be_valid
        review.justification = ''
        expect(review).not_to be_valid
      end

      it { is_expected.to be_weak_accept }
    end

    describe 'weak rejection' do
      subject(:review) { FactoryBot.build(:final_review) }

      before { review.recommendation.name = 'weak_reject' }

      it 'is valid with justification' do
        review.justification = 'I want to justify that the session is not so good...'
        expect(review).to be_valid
      end

      it 'is invalid without justification' do
        review.justification = nil
        expect(review).not_to be_valid
        review.justification = ''
        expect(review).not_to be_valid
      end

      it { is_expected.to be_weak_reject }
    end

    describe 'strong rejection' do
      subject(:review) { FactoryBot.build(:final_review) }

      before { review.recommendation.name = 'strong_reject' }

      it 'is valid with justification' do
        review.justification = 'I want to justify that the session sucks a lot...'
        expect(review).to be_valid
      end

      it 'is invalid without justification' do
        review.justification = nil
        expect(review).not_to be_valid
        review.justification = ''
        expect(review).not_to be_valid
      end

      it { is_expected.to be_strong_reject }
    end
  end

  describe 'callbacks' do
    it 'sets session in review after created' do
      review = FactoryBot.build(:final_review)
      review.save
      expect(review.session).to be_in_review
    end

    it 'does not set session in review if validation failed' do
      review = FactoryBot.build(:final_review, reviewer_id: nil)
      review.save
      expect(review.session).to be_created
    end
  end
end
