# frozen_string_literal: true

require 'spec_helper'

describe ReviewDecision, type: :model do
  it_should_trim_attributes ReviewDecision, :note_to_authors

  describe 'validations' do
    subject(:review_decision) { FactoryBot.build(:review_decision, session: session, outcome: outcome_with_title('outcomes.accept.title')) }

    let(:session) { FactoryBot.build(:session) }

    it { is_expected.to validate_presence_of :organizer_id }
    it { is_expected.to validate_presence_of :session_id }
    it { is_expected.to validate_presence_of :outcome_id }
    it { is_expected.to validate_presence_of :note_to_authors }

    should_validate_existence_of :organizer, :session, :outcome

    it 'validates outcome cant transition session on acceptance' do
      expect(review_decision).not_to be_valid
      expect(review_decision.errors[:session_id]).to include(I18n.t('activerecord.errors.models.review_decision.cant_accept'))
    end

    it 'validates outcome cant transition session on rejection' do
      review_decision.outcome = outcome_with_title('outcomes.reject.title')
      expect(review_decision).not_to be_valid
      expect(review_decision.errors[:session_id]).to include(I18n.t('activerecord.errors.models.review_decision.cant_reject'))
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :organizer }
    it { is_expected.to belong_to :session }
    it { is_expected.to belong_to :outcome }
  end

  describe 'callbacks' do
    it 'sets session pending confirmation after creating an accept review decision' do
      review_decision = review_decision_with_outcome('outcomes.accept.title')

      review_decision.save

      expect(review_decision.session).to be_pending_confirmation
    end

    it 'sets session rejected after creating a reject review decision' do
      review_decision = review_decision_with_outcome('outcomes.reject.title')

      review_decision.save

      expect(review_decision.session).to be_rejected
    end

    describe 'existing review decision' do
      context 'when rejected' do
        subject(:review_decision) { review_decision_with_outcome('outcomes.reject.title') }

        it 'sets session pending confirmation after being accepted' do
          review_decision.outcome = outcome_with_title('outcomes.accept.title')

          expect(review_decision.save).to be true
          expect(review_decision.session).to be_pending_confirmation
        end

        it 'justs update note after updating to reject a rejected session' do
          expect(review_decision.save).to be true
          expect(review_decision.session).to be_rejected
        end
      end

      context 'when accepted' do
        subject(:review_decision) { review_decision_with_outcome('outcomes.accept.title') }

        it 'sets session pending confirmation after being accepted' do
          expect(review_decision.save).to be true
          expect(review_decision.session).to be_pending_confirmation
        end

        it 'justs update note after updating to reject a rejected session' do
          review_decision.outcome = outcome_with_title('outcomes.reject.title')

          expect(review_decision.save).to be true
          expect(review_decision.session).to be_rejected
        end
      end
    end

    describe 'outcomes' do
      it 'accepted' do
        expect(review_decision_with_outcome('outcomes.accept.title')).to be_accepted
        expect(review_decision_with_outcome('outcomes.reject.title')).not_to be_accepted
      end

      it 'rejected' do
        expect(review_decision_with_outcome('outcomes.reject.title')).to be_rejected
        expect(review_decision_with_outcome('outcomes.accept.title')).not_to be_rejected
      end
    end
  end

  def review_decision_with_outcome(outcome)
    FactoryBot.build(:review_decision, outcome: outcome_with_title(outcome))
  end

  def outcome_with_title(outcome)
    Outcome.find_by(title: outcome) || FactoryBot.create(:outcome, title: outcome)
  end
end
