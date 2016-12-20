# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe EarlyReview, type: :model do
  before(:each) do
    EmailNotifications.stubs(:early_review_submitted).returns(stub(deliver_now: true))
  end

  it_should_trim_attributes EarlyReview, :comments_to_organizers, :comments_to_authors

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

  context 'validations' do
    it { should validate_presence_of :author_agile_xp_rating_id }
    it { should validate_presence_of :author_proposal_xp_rating_id }

    it { should validate_presence_of :proposal_quality_rating_id }
    it { should validate_presence_of :proposal_relevance_rating_id }

    it { should validate_presence_of :reviewer_confidence_rating_id }

    it { should validate_presence_of :reviewer_id }
    it { should validate_presence_of :session_id }

    it { should validate_length_of(:comments_to_authors).is_at_least(150) }

    context 'uniqueness' do
      before { FactoryGirl.create(:early_review) }
      it { should validate_uniqueness_of(:reviewer_id).scoped_to(:session_id, :type) }
    end
  end

  context 'notifications' do
    it 'should notify session author(s) after creation' do
      review = FactoryGirl.build(:early_review)
      EarlyReview.send(:public, :notify)

      EmailNotifications.expects(:early_review_submitted).with(review.session).returns(mock(deliver_now: true))

      review.notify
    end
  end
end
