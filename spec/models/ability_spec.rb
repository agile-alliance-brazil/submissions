# encoding: UTF-8
require 'spec_helper'

describe Ability do
  before(:each) do
    @user ||= FactoryGirl.build(:user)
    @conference = Conference.current
  end

  shared_examples_for "all users" do
    it "can read public entities" do
      @ability.should be_able_to(:read, User)
      @ability.should be_able_to(:read, Session)
      @ability.should be_able_to(:read, Comment)
      @ability.should be_able_to(:read, Track)
      @ability.should be_able_to(:read, SessionType)
      @ability.should be_able_to(:read, AudienceLevel)
      @ability.should be_able_to(:read, ActsAsTaggableOn::Tag)

      @ability.should be_able_to(:read, 'static_pages')
      @ability.should be_able_to(:read, 'accepted_sessions')
      @ability.should be_able_to(:manage, 'password_resets')
    end

    it "can create a new account" do
      @ability.should be_able_to(:create, User)
    end

    it "can update their own account" do
      @ability.should be_able_to(:update, @user)
      @user.id = 0
      @ability.should_not be_able_to(:update, @user)
    end

    it "can create comments" do
      @ability.should be_able_to(:create, Comment)
    end

    it "can edit their comments" do
      comment = FactoryGirl.build(:comment, :user => @user)
      @ability.should be_able_to(:edit, comment)
      comment.user_id = 0
      @ability.should_not be_able_to(:edit, comment)
    end

    it "can update their comments" do
      comment = FactoryGirl.build(:comment, :user => @user)
      @ability.should be_able_to(:update, comment)
      comment.user_id = 0
      @ability.should_not be_able_to(:update, comment)
    end

    it "can destroy their comments" do
      comment = FactoryGirl.build(:comment, :user => @user)
      @ability.should be_able_to(:destroy, comment)
      comment.user_id = 0
      @ability.should_not be_able_to(:destroy, comment)
    end
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "cannot manage reviewer" do
      @ability.should_not be_able_to(:manage, Reviewer)
    end

    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "cannot read reviews" do
      @ability.should_not be_able_to(:read, Review)
      @ability.should_not be_able_to(:read, FinalReview)
      @ability.should_not be_able_to(:read, EarlyReview)
    end

    it "cannot read reviews listing" do
      @ability.should_not be_able_to(:read, 'reviews_listing')
    end

    it "cannot read sessions to organize" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read organizer's reports" do
      @ability.should_not be_able_to(:read, 'organizer_reports')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    it "can accept reviewer invitation if invited" do
      reviewer = FactoryGirl.build(:reviewer, :user => @user)

      @ability = Ability.new(@user, @conference, nil, reviewer)
      @ability.should_not be_able_to(:manage, 'accept_reviewers')

      reviewer.state = 'invited'
      @ability.should be_able_to(:manage, 'accept_reviewers')
    end

    it "can reject reviewer invitation if invited" do
      reviewer = FactoryGirl.build(:reviewer, :user => @user)

      @ability = Ability.new(@user, @conference, nil, reviewer)
      @ability.should_not be_able_to(:manage, 'reject_reviewers')

      reviewer.state = 'invited'
      @ability.should be_able_to(:manage, 'reject_reviewers')
    end
  end

  context "- admin" do
    before(:each) do
      @user.add_role "admin"
      @ability = Ability.new(@user, @conference)
    end

    it "can manage all" do
      @ability.should be_able_to(:manage, :all)
    end
  end

  context "- author" do
    before(:each) do
      @user.add_role "author"
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "cannot manage reviewer" do
      @ability.should_not be_able_to(:manage, Reviewer)
    end

    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "cannot read reviews" do
      @ability.should_not be_able_to(:read, Review)
      @ability.should_not be_able_to(:read, FinalReview)
      @ability.should_not be_able_to(:read, EarlyReview)
    end

    context "index early reviews of" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "his sessions as first author is allowed" do
        @session.author = @user
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)
      end

      it "his sessions as second author is allowed" do
        @session.second_author = @user
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)
      end

      it "other people's sessions is forbidden" do
        session = FactoryGirl.build(:session)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should_not be_able_to(:index, EarlyReview, session)

        @ability = Ability.new(@user, @conference, session)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should_not be_able_to(:index, EarlyReview, session)
      end
    end

    context "index final reviews of" do
      before(:each) do
        @session = FactoryGirl.build(:session, :review_decision => FactoryGirl.build(:review_decision, :published => true))
      end

      it "his sessions as first author is allowed" do
        @session.author = @user
        @ability.should_not be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)
      end

      it "his sessions as second author is allowed" do
        @session.second_author = @user
        @ability.should_not be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)
      end

      it "his sessions if review has been published" do
        @session.author = @user
        @ability.should be_able_to(:index, FinalReview, @session)
        @session.review_decision.published = false
        @ability.should_not be_able_to(:index, FinalReview, @session)
      end

      it "other people's sessions is forbidden" do
        session = FactoryGirl.build(:session)
        @ability.should_not be_able_to(:index, FinalReview)
        @ability.should_not be_able_to(:index, FinalReview, session)

        @ability = Ability.new(@user, @conference, session)
        @ability.should_not be_able_to(:index, FinalReview)
        @ability.should_not be_able_to(:index, FinalReview, session)
      end
    end

    it "cannot read reviews listing" do
      @ability.should_not be_able_to(:read, 'reviews_listing')
    end

    it "cannot read sessions to organize" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read organizer's reports" do
      @ability.should_not be_able_to(:read, 'organizer_reports')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    describe "can create sessions if:" do
      it "in submissions phase" do
        @conference.expects(:in_submission_phase?).returns(true)
        @ability.should be_able_to(:create, Session)
      end

      it "out of submissions phase" do
        @conference.expects(:in_submission_phase?).returns(false)
        @ability.should_not be_able_to(:create, Session)
      end

      it "overides admin privileges to check for deadlines" do
        @user.add_role('admin')
        @conference.stubs(:in_submission_phase?).returns(false)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:create, Session)
        @ability.should_not be_able_to(:new, Session)
      end
    end

    describe "can update session if:" do
      before(:each) do
        @session = FactoryGirl.build(:session, :conference => @conference)
        @conference.stubs(:in_submission_phase?).returns(true)
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:update, @session)
        @session.author = @user
        @ability.should be_able_to(:update, @session)
      end

      it "- user is second author" do
        @ability.should_not be_able_to(:update, @session)
        @session.second_author = @user
        @ability.should be_able_to(:update, @session)
      end

      it "- in submissions phase" do
        @session.author = @user
        @conference.expects(:in_submission_phase?).returns(true)
        @ability.should be_able_to(:update, @session)
      end

      it "- out of submissions phase can't update" do
        @session.author = @user
        @conference.expects(:in_submission_phase?).returns(false)
        @ability.should_not be_able_to(:update, @session)
      end

      it "- session on current conference" do
        @session.author = @user
        @ability.should be_able_to(:update, @session)
        @session.conference = Conference.first
        @ability.should_not be_able_to(:update, @session)
      end
    end

    describe "can confirm session if:" do
      before(:each) do
        @another_user = FactoryGirl.build(:user)
        @session = FactoryGirl.build(:session,
          :author => @user,
          :state => 'pending_confirmation',
          :review_decision => FactoryGirl.build(:review_decision)
        )
        @conference.stubs(:in_author_confirmation_phase?).returns(true)
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.author = @another_user
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- user is second author" do
        @session.author = @another_user
        @session.second_author = @user

        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.state = 'rejected'
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- session has a review decision" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.review_decision = nil
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- outside of author confirmation phase can't confirm" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @conference.expects(:in_author_confirmation_phase?).returns(false)
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end
    end

    describe "can withdraw session if:" do
      before(:each) do
        @another_user = FactoryGirl.build(:user)
        @session = FactoryGirl.build(:session,
          :author => @user,
          :state => 'pending_confirmation',
          :review_decision => FactoryGirl.build(:review_decision)
        )
        @conference.stubs(:in_author_confirmation_phase?).returns(true)
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.author = @another_user
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- user is second author" do
        @session.author = @another_user
        @session.second_author = @user

        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.state = 'rejected'
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- session has a review decision" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.review_decision = nil
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- outside of author confirmation phase can't withdraw" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @conference.expects(:in_author_confirmation_phase?).returns(false)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end
    end

  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      Organizer.stubs(:user_organizing_conference?).with(@user, @conference).returns(true)
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "can manage reviewer" do
      @ability.should be_able_to(:manage, Reviewer)
    end

    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "can show reviews" do
      @ability.should be_able_to(:show, Review)
      @ability.should be_able_to(:show, FinalReview)
      @ability.should be_able_to(:show, EarlyReview)
    end

    it "can index review decisions" do
      @ability.should be_able_to(:index, ReviewDecision)
    end

    it "can read reviews listing" do
      @ability.should be_able_to(:read, 'reviews_listing')
      @ability.should_not be_able_to(:reviewer, 'reviews_listing')
    end

    it "can read sessions to organize" do
      @ability.should be_able_to(:read, 'organizer_sessions')
    end

    it "can read organizer report" do
      @ability.should be_able_to(:read, 'organizer_reports')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    context "organizer index reviews of" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "session on organizer's track is allowed" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should_not be_able_to(:organizer, FinalReview)
        @ability.should_not be_able_to(:organizer, EarlyReview)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:organizer, FinalReview)
        @ability.should be_able_to(:organizer, EarlyReview)
      end

      it "session outside of organizer's track is forbidden" do
        @ability.should_not be_able_to(:organizer, FinalReview)
        @ability.should_not be_able_to(:organizer, EarlyReview)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:organizer, FinalReview)
        @ability.should_not be_able_to(:organizer, EarlyReview)
      end
    end

    context "can cancel session if:" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "- session on organizer's track" do
        @ability.should_not be_able_to(:cancel, @session)

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:cancel, @session)
      end

      it "- session is not already cancelled" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:cancel, @session)
        @session.cancel
        @ability.should_not be_able_to(:cancel, @session)
      end
    end

    context "can create review decision if:" do
      before(:each) do
        @session = FactoryGirl.build(:session)
        @session.reviewing
        Time.zone.stubs(:now).returns(@conference.review_deadline + 1.day)
      end

      it "- session on organizer's track" do
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])

        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- after review deadline" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline + 1.second)

        @ability.should be_able_to(:create, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, ReviewDecision)
      end

      it "- before review deadline can't create review decision" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline)

        @ability.should_not be_able_to(:create, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- overrides admin privileges to check if session on organizer's track" do
        @user.add_role('admin')

        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- session is in review" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, ReviewDecision)

        @session.reject
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end
    end

    context "can edit review decision session" do
      before(:each) do
        @session = FactoryGirl.build(:session)
        @session.reviewing
        Time.zone.stubs(:now).returns(@conference.review_deadline + 1.day)
      end

      it " if session on organizer's track" do
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        FactoryGirl.build(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it " overrides admin privileges to check if session on organizer's track" do
        @user.add_role('admin')

        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        FactoryGirl.build(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "if session was not confirmed by author" do
        @session.tentatively_accept
        @session.accept

        FactoryGirl.build(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "unless session was rejected by author" do
        @session.tentatively_accept

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.reject
        @session.author_agreement = true
        @session.save

        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end

      it "unless session was accepted by author" do
        @session.tentatively_accept

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.accept
        @session.author_agreement = true
        @session.save

        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end

      it "if session has a review decision" do
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "if session is rejected" do
        @session.reject

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "if session is tentatively accepted" do
        @session.tentatively_accept

        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "after review deadline" do
        @session.tentatively_accept

        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline + 1.second)
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "before review deadline can't update review decision" do
        @session.tentatively_accept

        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline)
        @user.stubs(:organized_tracks).with(@conference).returns([@session.track])
        @ability.should_not be_able_to(:update, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
    end
  end

  context "- reviewer" do
    before(:each) do
      @user.add_role "reviewer"
      Reviewer.stubs(:user_reviewing_conference?).returns(true)
      # TODO: review this
      reviewer = FactoryGirl.build(:reviewer, :user => @user, :conference => @conference, :state => 'accepted')
      reviewer.preferences.build(:accepted => true, :track_id => @conference.tracks.first.id, :audience_level_id => @conference.audience_levels.first.id)
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "cannot read other reviewers" do
      @ability.should_not be_able_to(:read, Reviewer)
    end

    it "cannot read organizer's sessions" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read organizer's reports" do
      @ability.should_not be_able_to(:read, 'organizer_reports')
    end

    it "can read sessions to review" do
      @ability.should be_able_to(:read, 'reviewer_sessions')
    end

    it "can read reviews listing" do
      @ability.should be_able_to(:read, 'reviews_listing')
      @ability.should be_able_to(:reviewer, 'reviews_listing')
    end

    it "cannot index all reviews of any session" do
      @ability.should_not be_able_to(:index, Review)
      @ability.should_not be_able_to(:index, FinalReview)
      @ability.should_not be_able_to(:index, EarlyReview)
    end

    it "cannot index all organizer reviews of any session" do
      @ability.should_not be_able_to(:organizer, Review)
      @ability.should_not be_able_to(:organizer, FinalReview)
      @ability.should_not be_able_to(:organizer, EarlyReview)
    end

    it "can show own early reviews" do
      review = FactoryGirl.build(:early_review)
      @ability.should_not be_able_to(:show, review)
      review.reviewer = @user
      @ability.should be_able_to(:show, review)
    end

    it "can show own final reviews" do
      review = FactoryGirl.build(:final_review)
      @ability.should_not be_able_to(:show, review)
      review.reviewer = @user
      @ability.should be_able_to(:show, review)
    end

    context "can create a new final review if:" do
      before(:each) do
        @session = FactoryGirl.build(:session)
        Session.stubs(:for_reviewer).with(@user, @conference).returns([@session])
        @conference.stubs(:in_final_review_phase?).returns(true)
      end

      it "has a session available to add the final review to" do
        @ability.should_not be_able_to(:create, FinalReview)
        @ability.should_not be_able_to(:create, FinalReview, nil)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, FinalReview)
        @ability.should be_able_to(:create, FinalReview, nil)
        @ability.should be_able_to(:create, FinalReview, @session)
      end

      it "before final review deadline" do
        @conference.expects(:in_final_review_phase?).returns(true)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, FinalReview)
        @ability.should be_able_to(:create, FinalReview, nil)
        @ability.should be_able_to(:create, FinalReview, @session)
      end

      it "after final review deadline can't review" do
        @conference.stubs(:in_final_review_phase?).returns(false)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, FinalReview)
        @ability.should_not be_able_to(:create, FinalReview, nil)
        @ability.should_not be_able_to(:create, FinalReview, @session)
      end

      it "overrides admin privileges to check if session available" do
        @user.add_role('admin')

        @ability.should_not be_able_to(:create, FinalReview)
        @ability.should_not be_able_to(:create, FinalReview, nil)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, FinalReview)
        @ability.should be_able_to(:create, FinalReview, nil)
        @ability.should be_able_to(:create, FinalReview, @session)
      end
    end

    context "can create a new early review if:" do
      before(:each) do
        @session = FactoryGirl.build(:session)
        Session.stubs(:for_reviewer).with(@user, @conference).returns([@session])
        @conference.stubs(:in_early_review_phase?).returns(true)
      end

      it "has a session available to add the early review to" do
        @ability.should_not be_able_to(:create, EarlyReview)
        @ability.should_not be_able_to(:create, EarlyReview, nil)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, EarlyReview)
        @ability.should be_able_to(:create, EarlyReview, nil)
        @ability.should be_able_to(:create, EarlyReview, @session)
      end

      it "before early review deadline" do
        @conference.expects(:in_early_review_phase?).returns(true)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, EarlyReview)
        @ability.should be_able_to(:create, EarlyReview, nil)
        @ability.should be_able_to(:create, EarlyReview, @session)
      end

      it "after early review deadline can't review" do
        @conference.stubs(:in_early_review_phase?).returns(false)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, EarlyReview)
        @ability.should_not be_able_to(:create, EarlyReview, nil)
        @ability.should_not be_able_to(:create, EarlyReview, @session)
      end

      it "overrides admin privileges to check if session available" do
        @user.add_role('admin')

        @ability.should_not be_able_to(:create, EarlyReview)
        @ability.should_not be_able_to(:create, EarlyReview, nil)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, EarlyReview)
        @ability.should be_able_to(:create, EarlyReview, nil)
        @ability.should be_able_to(:create, EarlyReview, @session)
      end
    end
  end

  context "- voter" do
    before(:each) do
      @user.add_role "voter"
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "can read votes" do
      @ability.should be_able_to(:read, Vote)
    end

    context "can create a new vote if:" do
      before(:each) do
        @vote = FactoryGirl.build(:vote)
        @session = @vote.session
      end

      it "within limit for conference with session" do
        Vote.expects(:within_limit?).with(@user, @conference).twice.returns(true, false)
        @ability.should be_able_to(:create, Vote, @session)
        @ability.should_not be_able_to(:create, Vote, @session)
      end

      it "within limit for conference without session" do
        Vote.expects(:within_limit?).with(@user, @conference).twice.returns(true, false)
        @ability.should be_able_to(:create, Vote)
        @ability.should_not be_able_to(:create, Vote)
      end

      it "user is not first author" do
        @ability.should be_able_to(:create, Vote, @session)
        @ability.should be_able_to(:create, Vote)
        @session.author = @user
        @ability.should_not be_able_to(:create, Vote, @session)
        @ability.should be_able_to(:create, Vote)
      end

      it "user is not second author" do
        @ability.should be_able_to(:create, Vote, @session)
        @ability.should be_able_to(:create, Vote)
        @session.second_author = @user
        @ability.should_not be_able_to(:create, Vote, @session)
        @ability.should be_able_to(:create, Vote)
      end

      it "before voting deadline" do
        @conference.stubs(:in_voting_phase?).returns(true)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, Vote)
        @ability.should be_able_to(:create, Vote, nil)
        @ability.should be_able_to(:create, Vote, @session)
      end

      it "after voting deadline can't vote" do
        @conference.stubs(:in_voting_phase?).returns(false)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, Vote)
        @ability.should_not be_able_to(:create, Vote, nil)
        @ability.should_not be_able_to(:create, Vote, @session)
      end
    end

    context "can destroy votes if:" do
      before do
        @vote = FactoryGirl.build(:vote, :user => @user)
      end

      it "user is voter" do
        @ability.should be_able_to(:destroy, @vote)
        @vote.user_id = 0
        @ability.should_not be_able_to(:destroy, @vote)
      end

      it "before voting deadline" do
        @conference.stubs(:in_voting_phase?).returns(true)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:destroy, @vote)
      end

      it "after voting deadline can't destroy vote" do
        @conference.stubs(:in_voting_phase?).returns(false)
        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:destroy, @vote)
      end
    end
  end
end
