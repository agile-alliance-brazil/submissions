# frozen_string_literal: true

require 'spec_helper'

describe EarlyReview, type: :model do
  before do
    EmailNotifications.stubs(:early_review_submitted).returns(stub(deliver_now: true))
  end

  it_should_trim_attributes EarlyReview, :comments_to_organizers, :comments_to_authors

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

  describe 'validations' do
    it { is_expected.to validate_presence_of :author_agile_xp_rating_id }
    it { is_expected.to validate_presence_of :author_proposal_xp_rating_id }

    it { is_expected.to validate_presence_of :proposal_quality_rating_id }
    it { is_expected.to validate_presence_of :proposal_relevance_rating_id }

    it { is_expected.to validate_presence_of :reviewer_confidence_rating_id }

    it { is_expected.to validate_presence_of :reviewer_id }
    it { is_expected.to validate_presence_of :session_id }

    it { is_expected.to validate_length_of(:comments_to_authors).is_at_least(150) }

    describe 'uniqueness' do
      before { FactoryBot.create(:early_review) }

      it { is_expected.to validate_uniqueness_of(:reviewer_id).scoped_to(:session_id, :type) }
    end
  end

  describe 'notifications' do
    it 'notifies session author(s) after creation' do
      review = FactoryBot.build(:early_review)
      EarlyReview.send(:public, :notify)

      EmailNotifications.expects(:early_review_submitted).with(review.session).returns(mock(deliver_now: true))

      review.notify
    end
  end
end
