# frozen_string_literal: true

require 'spec_helper'

describe ReviewDecision, type: :model do
  it_should_trim_attributes ReviewDecision, :note_to_authors

  context 'validations' do
    it { should validate_presence_of :organizer_id }
    it { should validate_presence_of :session_id }
    it { should validate_presence_of :outcome_id }
    it { should validate_presence_of :note_to_authors }

    should_validate_existence_of :organizer, :session, :outcome

    it 'should validate outcome can transition session on acceptance' do
      session = FactoryBot.build(:session)
      review_decision = FactoryBot.build(:review_decision,
                                         session: session,
                                         outcome: outcome_with_title('outcomes.accept.title'))
      expect(review_decision).to_not be_valid
      expect(review_decision.errors[:session_id]).to include(I18n.t('activerecord.errors.models.review_decision.cant_accept'))
    end

    it 'should validate outcome can transition session on rejection' do
      session = FactoryBot.build(:session)
      review_decision = FactoryBot.build(:review_decision,
                                         session: session,
                                         outcome: outcome_with_title('outcomes.reject.title'))
      expect(review_decision).to_not be_valid
      expect(review_decision.errors[:session_id]).to include(I18n.t('activerecord.errors.models.review_decision.cant_reject'))
    end
  end

  context 'associations' do
    it { should belong_to :organizer }
    it { should belong_to :session }
    it { should belong_to :outcome }
  end

  context 'callbacks' do
    it 'should set session pending confirmation after creating an accept review decision' do
      review_decision = review_decision_with_outcome('outcomes.accept.title')

      review_decision.save

      expect(review_decision.session).to be_pending_confirmation
    end

    it 'should set session rejected after creating a reject review decision' do
      review_decision = review_decision_with_outcome('outcomes.reject.title')

      review_decision.save

      expect(review_decision.session).to be_rejected
    end

    context 'existing review decision' do
      it 'should set session pending confirmation after updating to accept' do
        @review_decision = review_decision_with_outcome('outcomes.reject.title')

        @review_decision.outcome = outcome_with_title('outcomes.accept.title')

        expect(@review_decision.save).to be true
        expect(@review_decision.session).to be_pending_confirmation
      end

      it 'should just update note after updating to accept a pending_confirmation session' do
        @review_decision = review_decision_with_outcome('outcomes.accept.title')

        @review_decision.outcome = outcome_with_title('outcomes.accept.title')

        expect(@review_decision.save).to be true
        expect(@review_decision.session).to be_pending_confirmation
      end

      it 'should just update note after updating to reject a rejected session' do
        @review_decision = review_decision_with_outcome('outcomes.reject.title')

        @review_decision.outcome = outcome_with_title('outcomes.reject.title')

        expect(@review_decision.save).to be true
        expect(@review_decision.session).to be_rejected
      end

      it 'should set session rejected after updating to reject' do
        @review_decision = review_decision_with_outcome('outcomes.accept.title')

        @review_decision.outcome = outcome_with_title('outcomes.reject.title')

        expect(@review_decision.save).to be true
        expect(@review_decision.session).to be_rejected
      end
    end

    context 'outcomes' do
      it 'accepted' do
        expect(review_decision_with_outcome('outcomes.accept.title')).to be_accepted
        expect(review_decision_with_outcome('outcomes.reject.title')).to_not be_accepted
      end

      it 'rejected' do
        expect(review_decision_with_outcome('outcomes.reject.title')).to be_rejected
        expect(review_decision_with_outcome('outcomes.accept.title')).to_not be_rejected
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
