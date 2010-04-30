require 'spec/spec_helper'

describe ReviewDecision do
  
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :organizer_id
    should_allow_mass_assignment_of :session_id
    should_allow_mass_assignment_of :outcome_id
    should_allow_mass_assignment_of :note_to_authors
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  it_should_trim_attributes ReviewDecision, :note_to_authors

  context "validations" do
    should_validate_presence_of :organizer_id
    should_validate_presence_of :session_id
    should_validate_presence_of :outcome_id
    should_validate_presence_of :note_to_authors
    
    it "should validate existence of organizer" do
      review_decision = Factory.build(:review_decision)
      review_decision.should be_valid
      review_decision.organizer_id = 0
      review_decision.should_not be_valid
      review_decision.errors.on(:organizer).should == "não existe"
    end

    it "should validate existence of session" do
      review_decision = Factory.build(:review_decision)
      review_decision.should be_valid
      review_decision.session_id = 0
      review_decision.should_not be_valid
      review_decision.errors.on(:session).should == "não existe"
    end

    it "should validate existence of outcome" do
      review_decision = Factory.build(:review_decision)
      review_decision.should be_valid
      review_decision.outcome_id = 0
      review_decision.should_not be_valid
      review_decision.errors.on(:outcome).should == "não existe"
    end
    
    it "should validate outcome can transition session on acceptance" do
      review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
      review_decision.should_not be_valid
      review_decision.errors.on(:session_id).should == "não pode ser aceita"
    end

    it "should validate outcome can transition session on rejection" do
      review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
      review_decision.should_not be_valid
      review_decision.errors.on(:session_id).should == "não pode ser rejeitada"
    end
  end
  
  context "associations" do
    should_belong_to :organizer, :class_name => "User"
    should_belong_to :session
    should_belong_to :outcome
  end

  context "callbacks" do
    it "should set session pending confirmation after creating an accept review decision" do
      review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
      review_decision.session.update_attribute(:state, 'in_review')
      review_decision.save
      review_decision.session.should be_pending_confirmation
    end
    
    it "should set session rejected after rejecting creating a reject review decision" do
      review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
      review_decision.session.update_attribute(:state, 'in_review')
      review_decision.save
      review_decision.session.should be_rejected
    end
    
    context "existing review decision" do
      it "should set session pending confirmation after updating to accept" do
        @review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
        @review_decision.session.update_attribute(:state, 'in_review')
        @review_decision.save
        
        @review_decision.outcome = Outcome.find_by_title('outcomes.accept.title')

        @review_decision.save.should be_true        
        @review_decision.session.should be_pending_confirmation
      end
      
      it "should just update note after updating to accept a pending_confirmation session" do
        @review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
        @review_decision.session.update_attribute(:state, 'in_review')
        @review_decision.save
        
        @review_decision.outcome = Outcome.find_by_title('outcomes.accept.title')

        @review_decision.save.should be_true        
        @review_decision.session.should be_pending_confirmation
      end
  
      it "should just update note after updating to reject a rejected session" do
        @review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.reject.title'))
        @review_decision.session.update_attribute(:state, 'in_review')
        @review_decision.save
      
        @review_decision.outcome = Outcome.find_by_title('outcomes.reject.title')

        @review_decision.save.should be_true      
        @review_decision.session.should be_rejected
      end
        
      it "should set session rejected after updating to reject" do
        @review_decision = Factory.build(:review_decision, :outcome => Outcome.find_by_title('outcomes.accept.title'))
        @review_decision.session.update_attribute(:state, 'in_review')
        @review_decision.save
        
        @review_decision.outcome = Outcome.find_by_title('outcomes.reject.title')

        @review_decision.save.should be_true
        @review_decision.session.should be_rejected
      end
    end
  end
end
