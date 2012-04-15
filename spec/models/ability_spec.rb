# encoding: UTF-8
require 'spec_helper'

describe Ability do
  before(:each) do
    @user = FactoryGirl.create(:user)
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
      @ability.should be_able_to(:manage, 'password_resets')
    end

    it "can create a new account" do
      @ability.should be_able_to(:create, User)
    end

    it "can update their own account" do
      @ability.should be_able_to(:update, @user)
      @ability.should_not be_able_to(:update, User.new)
    end

    it "can create comments" do
      @ability.should be_able_to(:create, Comment)
    end

    it "can edit their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:edit, comment)
      comment.user = @user
      @ability.should be_able_to(:edit, comment)
    end

    it "can update their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:update, comment)
      comment.user = @user
      @ability.should be_able_to(:update, comment)
    end

    it "can destroy their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:destroy, comment)
      comment.user = @user
      @ability.should be_able_to(:destroy, comment)
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
        @session = FactoryGirl.create(:session)
      end

      it "his sessions as first author is allowed" do
        @session.reload.update_attribute(:author_id, @user.id)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)
      end

      it "his sessions as second author is allowed" do
        @session.reload.update_attribute(:second_author_id, @user.id)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, EarlyReview)
        @ability.should be_able_to(:index, EarlyReview, @session)
      end

      it "other people's sessions is forbidden" do
        session = FactoryGirl.create(:session)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should_not be_able_to(:index, EarlyReview, session)

        @ability = Ability.new(@user, @conference, session)
        @ability.should_not be_able_to(:index, EarlyReview)
        @ability.should_not be_able_to(:index, EarlyReview, session)
      end
    end

    context "index final reviews of" do
      before(:each) do
        @decision = FactoryGirl.create(:review_decision, :published => true)
        @session = @decision.session
      end

      it "his sessions as first author is allowed" do
        @session.reload.update_attribute(:author_id, @user.id)
        @ability.should_not be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:index, FinalReview)
        @ability.should be_able_to(:index, FinalReview, @session)
      end

      it "his sessions as second author is allowed" do
        @session.reload.update_attribute(:second_author_id, @user.id)
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
        session = FactoryGirl.create(:session)
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

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    describe "can create sessions if:" do
      it "- in submissions phase" do
        @conference.expects(:in_submission_phase?).returns(true)
        @ability.should be_able_to(:create, Session)
      end

      it "- out of submissions phase" do
        @conference.expects(:in_submission_phase?).returns(false)
        @ability.should_not be_able_to(:create, Session)
      end
    end

    describe "can update session if:" do
      before(:each) do
        @session = FactoryGirl.create(:session, :conference => @conference)
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
        @another_user = FactoryGirl.create(:user)
        @session = FactoryGirl.create(:session, :author => @user)
        @session.reviewing
        FactoryGirl.create(:review_decision, :session => @session)
        @session.tentatively_accept
        Session.stubs(:find).returns(@session)
        Time.zone.stubs(:now).returns(@conference.author_confirmation - 1.week)
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.stubs(:author).returns(@another_user)
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- user is second author" do
        @session.stubs(:author).returns(@another_user)
        @session.stubs(:second_author).returns(@user)

        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.stubs(:pending_confirmation?).returns(false)
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- session has a review decision" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        @session.stubs(:review_decision).returns(nil)
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end

      it "- before deadline" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        Time.zone.expects(:now).at_least_once.returns(@conference.author_confirmation)
        @ability.should be_able_to(:manage, 'confirm_sessions')
      end

      it "- after deadline can't confirm" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')

        Time.zone.expects(:now).at_least_once.returns(@conference.author_confirmation + 1.second)
        @ability.should_not be_able_to(:manage, 'confirm_sessions')
      end
    end

    describe "can withdraw session if:" do
      before(:each) do
        @another_user = FactoryGirl.create(:user)
        @session = FactoryGirl.create(:session, :author => @user)
        @session.reviewing
        FactoryGirl.create(:review_decision, :session => @session)
        @session.tentatively_accept
        Session.stubs(:find).returns(@session)
        Time.zone.stubs(:now).returns(@conference.author_confirmation - 1.week)
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.stubs(:author).returns(@another_user)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- user is second author" do
        @session.stubs(:author).returns(@another_user)
        @session.stubs(:second_author).returns(@user)

        @ability.should_not be_able_to(:manage, 'confirm_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'confirm_sessions')
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.stubs(:pending_confirmation?).returns(false)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- session has a review decision" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        @session.stubs(:review_decision).returns(nil)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end

      it "- before deadline" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        Time.zone.expects(:now).at_least_once.returns(@conference.author_confirmation)
        @ability.should be_able_to(:manage, 'withdraw_sessions')
      end

      it "- after deadline can't withdraw" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:manage, 'withdraw_sessions')

        Time.zone.expects(:now).at_least_once.returns(@conference.author_confirmation + 1.second)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions')
      end
    end

  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      FactoryGirl.create(:organizer, :user => @user, :conference => @conference)
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

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    context "organizer index reviews of" do
      before(:each) do
        @session = FactoryGirl.create(:session)
      end

      it "session on organizer's track is allowed" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should_not be_able_to(:organizer, FinalReview)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:organizer, FinalReview)
      end

      it "session outside of organizer's track is forbidden" do
        @ability.should_not be_able_to(:organizer, FinalReview)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:organizer, FinalReview)
      end
    end

    context "can cancel session if:" do
      before(:each) do
        @session = FactoryGirl.create(:session)
      end

      it "- session on organizer's track" do
        @ability.should_not be_able_to(:cancel, @session)

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:cancel, @session)
      end

      it "- session is not already cancelled" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:cancel, @session)
        @session.cancel
        @ability.should_not be_able_to(:cancel, @session)
      end
    end

    context "can create review decision if:" do
      before(:each) do
        @session = FactoryGirl.create(:session)
        @session.reviewing
        Time.zone.stubs(:now).returns(@conference.review_deadline + 1.day)
      end

      it "- session on organizer's track" do
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)

        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- after review deadline" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline + 1.second)

        @ability.should be_able_to(:create, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:create, ReviewDecision)
      end

      it "- before review deadline can't create review decision" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
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

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- session is in review" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
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
        @session = FactoryGirl.create(:session)
        @session.reviewing
        Time.zone.stubs(:now).returns(@conference.review_deadline + 1.day)
      end

      it " if session on organizer's track" do
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user)
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

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "if session was not confirmed by author" do
        @session.tentatively_accept
        @session.accept

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "unless session was rejected by author" do
        @session.tentatively_accept

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.reject
        @session.author_agreement = true
        @session.save

        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end

      it "unless session was accepted by author" do
        @session.tentatively_accept

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.accept
        @session.author_agreement = true
        @session.save

        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end

      it "if session has a review decision" do
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "if session is rejected" do
        @session.reject

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "if session is tentatively accepted" do
        @session.tentatively_accept

        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "after review deadline" do
        @session.tentatively_accept

        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline + 1.second)
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should be_able_to(:update, ReviewDecision)
      end

      it "before review deadline can't update review decision" do
        @session.tentatively_accept

        Time.zone.expects(:now).at_least_once.returns(@conference.review_deadline)
        FactoryGirl.create(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)

        @ability = Ability.new(@user, @conference, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
    end
  end

  context "- reviewer" do
    before(:each) do
      @user.add_role "reviewer"
      reviewer = FactoryGirl.create(:reviewer, :user => @user, :conference => @conference)
      reviewer.invite
      reviewer.preferences.build(:accepted => true, :track_id => @conference.tracks.first.id, :audience_level_id => @conference.audience_levels.first.id, :conference_id => @conference.id)
      reviewer.accept
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

    it "can show own reviews" do
      review = FactoryGirl.create(:final_review)
      @ability.should_not be_able_to(:show, review)
      review.reviewer = @user
      @ability.should be_able_to(:show, review)
    end

    context "can create a new final review if:" do
      before(:each) do
        @session = FactoryGirl.create(:session)
        Session.stubs(:for_reviewer).with(@user, @conference).returns(Session)
        Session.stubs(:with_incomplete_final_reviews).returns([@session])
        @conference.stubs(:in_final_review_phase?).returns(true)
      end

      it "has not created a final review for this session" do
        @ability.should be_able_to(:create, FinalReview, @session)

        Session.expects(:with_incomplete_final_reviews).returns([])
        @ability.should_not be_able_to(:create, FinalReview, @session)
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
        @session = FactoryGirl.create(:session)
        Session.stubs(:for_reviewer).with(@user, @conference).returns(Session)
        Session.stubs(:incomplete_early_reviews_for).returns([@session])
        @conference.stubs(:in_early_review_phase?).returns(true)
      end

      it "has not created an early review for this session" do
        @ability.should be_able_to(:create, EarlyReview, @session)

        Session.expects(:incomplete_early_reviews_for).with(@conference).returns([])

        @ability.should_not be_able_to(:create, EarlyReview, @session)
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
end