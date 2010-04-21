require 'spec/spec_helper'

describe ReviewDecision do
  
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :session_id
    should_allow_mass_assignment_of :outcome_id
    should_allow_mass_assignment_of :note_to_authors
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  it_should_trim_attributes ReviewDecision, :note_to_authors

  context "validations" do
    should_validate_presence_of :session_id
    should_validate_presence_of :outcome_id
    should_validate_presence_of :note_to_authors
    
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
  end
  
  context "associations" do
    should_belong_to :session
    should_belong_to :outcome
  end
end
