require 'spec/spec_helper'

describe Preference do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :reviewer_id
    should_allow_mass_assignment_of :track_id
    should_allow_mass_assignment_of :audience_level_id
    should_allow_mass_assignment_of :accepted
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  context "validations" do
    should_validate_inclusion_of :accepted, :in => [true, false]
    
    describe "should validate presence of audience level if accepted" do
      subject {Factory(:preference, :accepted => true)}
      should_validate_presence_of :audience_level_id
    end
    
    it "should validate existence of reviewer" do
      preference = Factory.build(:preference)
      preference.should be_valid
      preference.reviewer_id = 0
      preference.should_not be_valid
      preference.errors.on(:reviewer).should == "não existe"
    end

    it "should validate existence of track" do
      preference = Factory.build(:preference)
      preference.should be_valid
      preference.track_id = 0
      preference.should_not be_valid
      preference.errors.on(:track).should == "não existe"
    end

    it "should validate existence of audience level" do
      preference = Factory.build(:preference)
      preference.should be_valid
      preference.audience_level_id = 0
      preference.should_not be_valid
      preference.errors.on(:audience_level).should == "não existe"
    end
  end
  
  context "associations" do
    should_belong_to :reviewer
    should_belong_to :track
    should_belong_to :audience_level
    
    should_have_one :user, :through => :reviewer
  end
end