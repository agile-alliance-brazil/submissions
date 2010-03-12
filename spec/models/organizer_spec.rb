require 'spec/spec_helper'

describe Organizer do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :user_id
    should_allow_mass_assignment_of :track_id
  
    should_not_allow_mass_assignment_of :evil_attr
  end

  context "validations" do
    should_validate_presence_of :user_id
    should_validate_presence_of :track_id
    
    it "should validate existence of user" do
      organizer = Factory.build(:organizer)
      organizer.should be_valid
      organizer.user_id = 0
      organizer.should_not be_valid
      organizer.errors.on(:user).should == "não existe"
    end

    it "should validate existence of track" do
      organizer = Factory.build(:organizer)
      organizer.should be_valid
      organizer.track_id = 0
      organizer.should_not be_valid
      organizer.errors.on(:track).should == "não existe"
    end
  end
  
  context "associations" do
    should_belong_to :user
    should_belong_to :track
  end
  
  context "managing organizer role" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should make given user organizer role after created" do
      @user.should_not be_organizer
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
    end
    
    it "should remove organizer role after destroyed" do
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
      organizer.destroy
      @user.should_not be_organizer
    end
    
    it "should keep organizer role after destroyed if user organizes other tracks" do
      Factory(:organizer, :user => @user)
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
      organizer.destroy
      @user.should be_organizer
    end
  end
end
