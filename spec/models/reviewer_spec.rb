# encoding: UTF-8
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
    it { should validate_presence_of :conference_id }

    context "uniqueness" do
      before { FactoryGirl.create(:reviewer) }
      it { should validate_uniqueness_of(:user_id).scoped_to(:conference_id) }
    end

    should_validate_existence_of :conference, :user

    it "should validate that at least 1 preference was accepted" do
      reviewer = FactoryGirl.create(:reviewer)
      reviewer.preferences.build(:accepted => false)
      reviewer.accept.should be_false
      reviewer.errors[:base].should include(I18n.t("activerecord.errors.models.reviewer.preferences"))
    end

    it "should validate that reviewer agreement was accepted" do
      reviewer = FactoryGirl.create(:reviewer, :reviewer_agreement => false)
      reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
      reviewer.accept.should be_false
      reviewer.errors[:reviewer_agreement].should include(I18n.t("errors.messages.accepted"))
    end

    it "should copy user errors to user_username" do
      reviewer = FactoryGirl.create(:reviewer)
      new_reviewer = FactoryGirl.build(:reviewer, :user => reviewer.user, :conference => reviewer.conference)
      new_reviewer.should_not be_valid
      new_reviewer.errors[:user_username].should include(I18n.t("activerecord.errors.messages.taken"))
    end

    context "user" do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer)
      end

      it "should be a valid user" do
        @reviewer.user_username = 'invalid_username'
        @reviewer.should_not be_valid
        @reviewer.errors[:user_username].should include(I18n.t("activerecord.errors.messages.existence"))
      end
    end
  end

  context "associations" do
    it { should belong_to :user }
    it { should belong_to :conference }
    it { should have_many(:preferences).dependent(:destroy) }
    it { should have_many(:accepted_preferences).class_name('Preference') }

    it { should accept_nested_attributes_for :preferences }

    context "reviewer username" do
      subject { FactoryGirl.build(:reviewer) }
      it_should_behave_like "virtual username attribute", :user
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
        EmailNotifications.expects(:reviewer_invitation).with(@reviewer).returns(mock(:deliver => true))
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
        # TODO: review this
        @reviewer.preferences.build(:accepted => true, :track_id => @reviewer.conference.tracks.first.id, :audience_level_id => @reviewer.conference.audience_levels.first.id)
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
        # TODO: review this
        @reviewer.preferences.build(:accepted => true, :track_id => @reviewer.conference.tracks.first.id, :audience_level_id => @reviewer.conference.audience_levels.first.id)
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
    it "should make given user reviewer role after invitation accepted" do
      reviewer = FactoryGirl.create(:reviewer, :user => subject)
      reviewer.invite
      subject.should_not be_reviewer
      # TODO: review this
      reviewer.preferences.build(:accepted => true, :track_id => reviewer.conference.tracks.first.id, :audience_level_id => reviewer.conference.audience_levels.first.id)
      reviewer.accept
      subject.should be_reviewer
      subject.reload.should be_reviewer
    end

    it "should remove organizer role after destroyed" do
      reviewer = FactoryGirl.create(:reviewer, :user => subject)
      reviewer.invite
      # TODO: review this
      reviewer.preferences.build(:accepted => true, :track_id => reviewer.conference.tracks.first.id, :audience_level_id => reviewer.conference.audience_levels.first.id)
      reviewer.accept
      subject.should be_reviewer
      reviewer.destroy
      subject.should_not be_reviewer
      subject.reload.should_not be_reviewer
    end
  end

  context "managing reviewer role for complete user" do
    subject { FactoryGirl.create(:user) }
    it_should_behave_like "reviewer role"
  end

  context "managing reviewer role for simple user" do
    subject { FactoryGirl.create(:simple_user) }
    it_should_behave_like "reviewer role"
  end

  context "checking if able to review a track" do
    before(:each) do
      @organizer = FactoryGirl.create(:organizer)
      @reviewer = FactoryGirl.create(:reviewer, :user => @organizer.user)
    end

    it "can review track when not organizer" do
      @reviewer.should be_can_review(FactoryGirl.create(:track))
    end

    it "can not review track when organizer on the same conference" do
      @reviewer.should_not be_can_review(@organizer.track)
    end

    it "can review track when organizer for different conference" do
      reviewer = FactoryGirl.create(:reviewer, :user => @organizer.user, :conference => Conference.first)
      reviewer.should be_can_review(@organizer.track)
    end
  end

  context "display name rules" do
    subject { FactoryGirl.build(:user, first_name: "Raphael", last_name: "Molesim") }
    it "should display reviewer name if he decided to sign reviews" do
      reviewer = FactoryGirl.build(:reviewer, :user => subject, sign_reviews: true)
      reviewer.display_name.should == "Raphael Molesim"
    end
    it "should not display reviewer name if he decided to not sign reviews" do
      reviewer = FactoryGirl.build(:reviewer, :user => subject, sign_reviews: false)
      reviewer.display_name.should == "Avaliador"
    end
    it "should not display reviewer name and should optionally concat with a index" do
      reviewer = FactoryGirl.build(:reviewer, :user => subject, sign_reviews: false)
      reviewer.display_name(1).should == "Avaliador 1"
    end
  end

end
