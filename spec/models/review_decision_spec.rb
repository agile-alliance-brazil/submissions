# encoding: UTF-8
require 'spec_helper'

describe ReviewDecision do

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :organizer_id }
    it { should allow_mass_assignment_of :session_id }
    it { should allow_mass_assignment_of :outcome_id }
    it { should allow_mass_assignment_of :note_to_authors }

    it { should_not allow_mass_assignment_of :id }
  end

  it_should_trim_attributes ReviewDecision, :note_to_authors

  context "validations" do
    it { should validate_presence_of :organizer_id }
    it { should validate_presence_of :session_id }
    it { should validate_presence_of :outcome_id }
    it { should validate_presence_of :note_to_authors }
    should_validate_existence_of :organizer, :session, :outcome

    it "should validate outcome can transition session on acceptance" do
      review_decision = FactoryGirl.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
      review_decision.should_not be_valid
      review_decision.errors[:session_id].should include(I18n.t("activerecord.errors.models.review_decision.cant_accept"))
    end

    it "should validate outcome can transition session on rejection" do
      review_decision = FactoryGirl.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
      review_decision.should_not be_valid
      review_decision.errors[:session_id].should include(I18n.t("activerecord.errors.models.review_decision.cant_reject"))
    end
  end

  context "associations" do
    it { should belong_to :organizer }
    it { should belong_to :session }
    it { should belong_to :outcome }
  end

  context "callbacks" do
    it "should set session pending confirmation after creating an accept review decision" do
      review_decision = review_decision_with_outcome('outcomes.accept.title')

      review_decision.session.should be_pending_confirmation
    end

    it "should set session rejected after rejecting creating a reject review decision" do
      review_decision = review_decision_with_outcome('outcomes.reject.title')

      review_decision.session.should be_rejected
    end

    context "existing review decision" do
      it "should set session pending confirmation after updating to accept" do
        @review_decision = review_decision_with_outcome('outcomes.reject.title')

        @review_decision.outcome = Outcome.find_by_title('outcomes.accept.title')

        @review_decision.save.should be_true
        @review_decision.session.should be_pending_confirmation
      end

      it "should just update note after updating to accept a pending_confirmation session" do
        @review_decision = review_decision_with_outcome('outcomes.accept.title')

        @review_decision.outcome = Outcome.find_by_title('outcomes.accept.title')

        @review_decision.save.should be_true
        @review_decision.session.should be_pending_confirmation
      end

      it "should just update note after updating to reject a rejected session" do
        @review_decision = review_decision_with_outcome('outcomes.reject.title')

        @review_decision.outcome = Outcome.find_by_title('outcomes.reject.title')

        @review_decision.save.should be_true
        @review_decision.session.should be_rejected
      end

      it "should set session rejected after updating to reject" do
        @review_decision = review_decision_with_outcome('outcomes.accept.title')

        @review_decision.outcome = Outcome.find_by_title('outcomes.reject.title')

        @review_decision.save.should be_true
        @review_decision.session.should be_rejected
      end
    end

    context "outcomes" do
      it "accepted" do
        review_decision_with_outcome('outcomes.accept.title').should be_accepted
        review_decision_with_outcome('outcomes.reject.title').should_not be_accepted
      end

      it "rejected" do
        review_decision_with_outcome('outcomes.reject.title').should be_rejected
        review_decision_with_outcome('outcomes.accept.title').should_not be_rejected
      end
    end
  end

  def review_decision_with_outcome(outcome)
    review_decision = FactoryGirl.build(:review_decision, :outcome => Outcome.find_by_title(outcome))
    review_decision.session.update_attribute(:state, 'in_review')
    review_decision.save
    review_decision
  end
end
