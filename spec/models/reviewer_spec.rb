# encoding: UTF-8
# encoding: utf-8
require 'spec_helper'

describe Reviewer do
  before(:each) do
    EmailNotifications.stubs(:reviewer_invitation).returns(stub(:deliver => true))
  end
  
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :user_id }
    it { should allow_mass_assignment_of :conference_id }
    it { should allow_mass_assignment_of :user_username }
    it { should allow_mass_assignment_of :preferences_attributes }
    it { should allow_mass_assignment_of :reviewer_agreement }
    it { should allow_mass_assignment_of :state_event }

    it { should_not allow_mass_assignment_of :id }
  end
  
  it_should_trim_attributes Reviewer, :user_username

  context "validations" do
    it { should validate_presence_of :user_username }
    it { should validate_presence_of :conference_id }
    
    context "uniqueness" do
      before { FactoryGirl.create(:reviewer) }
      it { should validate_uniqueness_of(:user_id).scoped_to(:conference_id) }
    end

    should_validate_existence_of :user, :conference
    
    it "should validate that at least 1 preference was accepted" do
      reviewer = FactoryGirl.create(:reviewer)
      reviewer.preferences.build(:accepted => false)
      reviewer.accept.should be_false
      reviewer.errors[:base].should include("pelo menos uma trilha deve ser aceita")
    end

    it "should validate that reviewer agreement was accepted" do
      reviewer = FactoryGirl.create(:reviewer, :reviewer_agreement => false)
      reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
      reviewer.accept.should be_false
      reviewer.errors[:reviewer_agreement].should include("deve ser aceito")
    end
    
    it "should copy user errors to user_username" do
      reviewer = FactoryGirl.create(:reviewer)
      new_reviewer = FactoryGirl.build(:reviewer, :user => reviewer.user, :conference => reviewer.conference)
      new_reviewer.should_not be_valid
      new_reviewer.errors[:user_username].should include("já está em uso")
    end

    context "user" do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer)
      end
      
      it "should be a valid user" do
        @reviewer.user_username = 'invalid_username'
        @reviewer.should_not be_valid
        @reviewer.errors[:user_username].should include("não existe")
      end
    end      
  end
  
  context "associations" do
    it { should belong_to :user }
    it { should belong_to :conference }
    it { should have_many :preferences }
    it { should have_many(:accepted_preferences).class_name('Preference') }

    xit { should accept_nested_attributes_for :preferences }

    context "user association by username" do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer)
        @user = FactoryGirl.create(:user)
      end
      
      it "should set by username" do
        @reviewer.user_username = @user.username
        @reviewer.user.should == @user
      end
    
      it "should not set if username is nil" do
        @reviewer.user_username = nil
        @reviewer.user.should be_nil
      end

      it "should not set if username is empty" do
        @reviewer.user_username = ""
        @reviewer.user.should be_nil
      end

      it "should not set if username is only spaces" do
        @reviewer.user_username = "  "
        @reviewer.user.should be_nil
      end
      
      it "should provide username from association" do
        @reviewer.user_username = @user.username
        @reviewer.user_username.should == @user.username
      end
    end
  end
  
  context "state machine" do
    before(:each) do
      @reviewer = FactoryGirl.build(:reviewer)
    end
    
    context "State: created" do
      it "should be the initial state" do
        @reviewer.should be_created
      end
      
      it "should allow invite" do
        @reviewer.invite.should be_true
        @reviewer.should_not be_created
        @reviewer.should be_invited
      end

      it "should not allow accept" do
        @reviewer.accept.should be_false
      end

      it "should not allow reject" do
        @reviewer.reject.should be_false
      end
    end
    
    context "Event: invite" do
      it "should send invitation email" do
        EmailNotifications.expects(:reviewer_invitation).with(@reviewer).returns(stub(:deliver => true))
        @reviewer.invite
      end
    end
    
    context "State: invited" do
      before(:each) do
        @reviewer.invite
        @reviewer.should be_invited
      end
      
      it "should allow inviting again" do
        @reviewer.invite.should be_true
        @reviewer.should be_invited
      end
      
      it "should allow accepting" do
        @reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
        @reviewer.accept.should be_true
        @reviewer.should_not be_invited
        @reviewer.should be_accepted
      end

      it "should allow rejecting" do
        @reviewer.reject.should be_true
        @reviewer.should_not be_invited
        @reviewer.should be_rejected
      end
    end

    context "State: accepted" do
      before(:each) do
        @reviewer.invite
        @reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
        @reviewer.accept
        @reviewer.should be_accepted
      end
      
      it "should not allow invite" do
        @reviewer.invite.should be_false
      end
      
      it "should not allow accepting" do
        @reviewer.accept.should be_false
      end

      it "should not allow rejecting" do
        @reviewer.reject.should be_false
      end
    end

    context "State: rejected" do
      before(:each) do
        @reviewer.invite
        @reviewer.reject
        @reviewer.should be_rejected
      end
      
      it "should not allow invite" do
        @reviewer.invite.should be_false
      end
      
      it "should not allow accepting" do
        @reviewer.accept.should be_false
      end

      it "should not allow rejecting" do
        @reviewer.reject.should be_false
      end
    end
  end
  
  context "callbacks" do
    it "should invite after created" do
      reviewer = FactoryGirl.build(:reviewer)
      reviewer.save
      reviewer.should be_invited
    end
    
    it "should not invite if validation failed" do
      reviewer = FactoryGirl.build(:reviewer, :user_id => nil)
      reviewer.save
      reviewer.should_not be_invited
    end
  end

  shared_examples_for "reviewer role" do
    before do
      @conference = FactoryGirl.create(:conference)
    end

    it "should make given user reviewer role after invitation accepted" do
      reviewer = FactoryGirl.create(:reviewer, :user => @user, :conference => @conference)
      reviewer.invite
      @user.should_not be_reviewer
      reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
      reviewer.accept
      @user.should be_reviewer
      @user.reload.should be_reviewer
    end
    
    it "should remove organizer role after destroyed" do
      reviewer = FactoryGirl.create(:reviewer, :user => @user, :conference => @conference)
      reviewer.invite
      reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
      reviewer.accept
      @user.should be_reviewer
      reviewer.destroy
      @user.should_not be_reviewer
      @user.reload.should_not be_reviewer
    end
  end
  
  context "managing reviewer role for complete user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    
    it_should_behave_like "reviewer role"
  end

  context "managing reviewer role for simple user" do
    before(:each) do
      @user = FactoryGirl.create(:simple_user)
    end
    
    it_should_behave_like "reviewer role"
  end
  
  context "checking if able to review a track" do
    before(:each) do
      @organizer = FactoryGirl.create(:organizer)
      @reviewer = FactoryGirl.create(:reviewer, :user => @organizer.user, :conference => @organizer.conference)
    end
    
    it "can review track when not organizer" do
      @reviewer.should be_can_review(FactoryGirl.create(:track))
    end
    
    it "can not review track when organizer on the same conference" do
      @reviewer.should_not be_can_review(@organizer.track)
    end

    it "can review track when organizer for different conference" do
      reviewer = FactoryGirl.create(:reviewer, :user => @organizer.user)
      reviewer.should be_can_review(@organizer.track)
    end
  end
end
