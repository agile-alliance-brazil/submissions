# encoding: utf-8
require 'spec_helper'

describe Organizer do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :user_id
    should_allow_mass_assignment_of :track_id
    should_allow_mass_assignment_of :user_username
  
    should_not_allow_mass_assignment_of :id
  end
  
  it_should_trim_attributes Organizer, :user_username

  context "validations" do
    before { Factory(:organizer) }
    should_validate_presence_of :user_username
    should_validate_presence_of :track_id
    should_validate_uniqueness_of :track_id, :scope => :user_id

    should_validate_existence_of :user, :track

    context "user" do
      it "should be a valid user" do
        organizer = Factory(:organizer)
        organizer.user_username = 'invalid_username'
        organizer.should_not be_valid
        organizer.errors[:user_username].should include("não existe")
      end
    end      
  end
  
  context "associations" do
    should_belong_to :user
    should_belong_to :track

    context "user association by username" do
      before(:each) do
        @organizer = Factory(:organizer)
        @user = Factory(:user)
      end
      
      it "should set by username" do
        @organizer.user_username = @user.username
        @organizer.user.should == @user
      end
    
      it "should not set if username is nil" do
        @organizer.user_username = nil
        @organizer.user.should be_nil
      end

      it "should not set if username is empty" do
        @organizer.user_username = ""
        @organizer.user.should be_nil
      end

      it "should not set if username is only spaces" do
        @organizer.user_username = "  "
        @organizer.user.should be_nil
      end
      
      it "should provide username from association" do
        @organizer.user_username = @user.username
        @organizer.user_username.should == @user.username
      end
    end
  end
  
  shared_examples_for "organizer role" do
    it "should make given user organizer role after created" do
      @user.should_not be_organizer
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
      @user.reload.should be_organizer
    end
    
    it "should remove organizer role after destroyed" do
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
      organizer.destroy
      @user.should_not be_organizer
      @user.reload.should_not be_organizer
    end
    
    it "should keep organizer role after destroyed if user organizes other tracks" do
      Factory(:organizer, :user => @user)
      organizer = Factory(:organizer, :user => @user)
      @user.should be_organizer
      organizer.destroy
      @user.should be_organizer
      @user.reload.should be_organizer
    end
    
    it "should remove organizer role after update" do
      organizer = Factory(:organizer, :user => @user)
      another_user = Factory(:user)
      organizer.user = another_user
      organizer.save
      @user.reload.should_not be_organizer
      another_user.should be_organizer
    end

    it "should keep organizer role after update if user organizes other tracks" do
      Factory(:organizer, :user => @user)
      organizer = Factory(:organizer, :user => @user)
      another_user = Factory(:user)
      organizer.user = another_user
      organizer.save
      @user.reload.should be_organizer
      another_user.should be_organizer
    end
  end
  
  context "managing organizer role for normal user" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it_should_behave_like "organizer role"
  end

  context "managing organizer role for simple user" do
    before(:each) do
      @user = Factory(:simple_user)
    end
    
    it_should_behave_like "organizer role"
  end
end
