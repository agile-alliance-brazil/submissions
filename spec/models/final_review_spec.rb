# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe FinalReview, type: :model do
  it_should_trim_attributes FinalReview, :comments_to_organizers, :comments_to_authors, :justification

  context 'associations' do
    it { should belong_to :reviewer }
    it { should belong_to :session }
    it { should belong_to :recommendation }

    it { should belong_to :author_agile_xp_rating }
    it { should belong_to :author_proposal_xp_rating }
    it { should belong_to :proposal_quality_rating }
    it { should belong_to :proposal_relevance_rating }
    it { should belong_to :reviewer_confidence_rating }

    it { should have_many :review_evaluations }
  end

  it "should determine if it's strong accept" do
    strong = FactoryGirl.build(:recommendation, name: 'strong_accept')
    review = FactoryGirl.build(:final_review)
    expect(review).to_not be_strong_accept
    review.recommendation = strong
    expect(review).to be_strong_accept
  end

  context 'validations' do
    it { should validate_presence_of :author_agile_xp_rating_id }
    it { should validate_presence_of :author_proposal_xp_rating_id }

    it { should validate_presence_of :proposal_quality_rating_id }
    it { should validate_presence_of :proposal_relevance_rating_id }

    it { should validate_presence_of :recommendation_id }

    it { should validate_presence_of :reviewer_confidence_rating_id }

    it { should validate_presence_of :reviewer_id }
    it { should validate_presence_of :session_id }

    it { should validate_length_of(:comments_to_authors).is_at_least(150) }

    context 'uniqueness' do
      before { FactoryGirl.create(:final_review) }
      it { should validate_uniqueness_of(:reviewer_id).scoped_to(:session_id, :type) }
    end

    context 'strong acceptance' do
      subject { FactoryGirl.build(:final_review) }
      before(:each) { subject.recommendation.name = 'strong_accept' }

      it 'should not validate presence of justification' do
        subject.justification = nil
        expect(subject).to be_valid
        subject.justification = 'I want to justify that the session rules!'
        expect(subject).to be_valid
      end

      it { should be_strong_accept }
    end

    context 'weak acceptance' do
      subject { FactoryGirl.build(:final_review) }
      before(:each) { subject.recommendation.name = 'weak_accept' }

      it 'should validate presence of justification' do
        subject.justification = nil
        expect(subject).to_not be_valid
        subject.justification = ''
        expect(subject).to_not be_valid
        subject.justification = 'I want to justify that the session is ok.'
        expect(subject).to be_valid
      end

      it { should be_weak_accept }
    end

    context 'weak rejection' do
      subject { FactoryGirl.build(:final_review) }
      before(:each) { subject.recommendation.name = 'weak_reject' }

      it 'should validate presence of justification' do
        subject.justification = nil
        expect(subject).to_not be_valid
        subject.justification = ''
        expect(subject).to_not be_valid
        subject.justification = 'I want to justify that the session is not so good...'
        expect(subject).to be_valid
      end

      it { should be_weak_reject }
    end

    context 'strong rejection' do
      subject { FactoryGirl.build(:final_review) }
      before(:each) { subject.recommendation.name = 'strong_reject' }

      it 'should validate presence of justification' do
        subject.justification = nil
        expect(subject).to_not be_valid
        subject.justification = ''
        expect(subject).to_not be_valid
        subject.justification = 'I want to justify that the session sucks a lot...'
        expect(subject).to be_valid
      end

      it { should be_strong_reject }
    end
  end

  context 'callbacks' do
    it 'should set session in review after created' do
      review = FactoryGirl.build(:final_review)
      review.save
      expect(review.session).to be_in_review
    end

    it 'should not set session in review if validation failed' do
      review = FactoryGirl.build(:final_review, reviewer_id: nil)
      review.save
      expect(review.session).to be_created
    end
  end
end
