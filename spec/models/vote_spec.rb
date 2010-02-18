require 'spec/spec_helper'

describe Vote do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :logo_id
    should_allow_mass_assignment_of :user_id
    should_allow_mass_assignment_of :user_ip
  
    should_not_allow_mass_assignment_of :evil_attr
  end

  context "validations" do
    before { Factory(:vote) }
    should_validate_presence_of :user_ip
    should_validate_presence_of :logo_id
    should_validate_uniqueness_of :user_id
    
    it "should validate existence of user" do
      vote = Factory.build(:vote)
      vote.should be_valid
      vote.user_id = 0
      vote.should_not be_valid
      vote.errors.on(:user).should == "não existe"
    end

    it "should validate existence of logo" do
      vote = Factory.build(:vote)
      vote.should be_valid
      vote.logo_id = 0
      vote.should_not be_valid
      vote.errors.on(:logo).should == "não existe"
    end
  end
  
  context "associations" do
    should_belong_to :user
    should_belong_to :logo
  end
  
  context "named scopes" do
    should_have_scope :for_user, :conditions => ['user_id = ?', 3], :with => '3'
  end
  
end
