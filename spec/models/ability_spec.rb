# frozen_string_literal: true

require 'spec_helper'

describe Ability, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:conference) { FactoryBot.create(:conference) }
  let(:ability) { Ability.new(user, conference) }

  before(:each) do
    Conference.stubs(:current).returns(conference)
  end

  shared_examples_for 'all users' do
    it 'can read public entities' do
      expect(ability).to be_able_to(:read, User)
      expect(ability).to be_able_to(:read, Conference)
      expect(ability).to be_able_to(:read, Page)
      expect(ability).to be_able_to(:read, Session)
      expect(ability).to be_able_to(:read, Comment)
      expect(ability).to be_able_to(:read, Track)
      expect(ability).to be_able_to(:read, SessionType)
      expect(ability).to be_able_to(:read, AudienceLevel)
      expect(ability).to be_able_to(:read, ActsAsTaggableOn::Tag)

      expect(ability).to be_able_to(:read, 'static_pages')
      expect(ability).to be_able_to(:manage, 'password_resets')
    end

    it 'can create a new account' do
      expect(ability).to be_able_to(:create, User)
    end

    it 'can update their own account' do
      expect(ability).to be_able_to(:update, user)
      user.id = 0
      expect(ability).to_not be_able_to(:update, user)
    end

    it 'can create comments' do
      expect(ability).to be_able_to(:create, Comment)
    end

    it 'can edit their comments' do
      comment = FactoryBot.build(:comment, user: user)
      expect(ability).to be_able_to(:edit, comment)
      comment.user_id = 0
      expect(ability).to_not be_able_to(:edit, comment)
    end

    it 'can update their comments' do
      comment = FactoryBot.build(:comment, user: user)
      expect(ability).to be_able_to(:update, comment)
      comment.user_id = 0
      expect(ability).to_not be_able_to(:update, comment)
    end

    it 'can destroy their comments' do
      comment = FactoryBot.build(:comment, user: user)
      expect(ability).to be_able_to(:destroy, comment)
      comment.user_id = 0
      expect(ability).to_not be_able_to(:destroy, comment)
    end
  end

  context '- all users (guests)' do
    it_should_behave_like 'all users'

    it 'cannot manage reviewer' do
      expect(ability).to_not be_able_to(:manage, Reviewer)
    end

    it 'cannot read organizers' do
      expect(ability).to_not be_able_to(:read, Organizer)
    end

    it 'cannot read reviews' do
      expect(ability).to_not be_able_to(:read, Review)
      expect(ability).to_not be_able_to(:read, FinalReview)
      expect(ability).to_not be_able_to(:read, EarlyReview)
    end

    it 'cannot read reviews listing' do
      expect(ability).to_not be_able_to(:read, 'reviews_listing')
    end

    it 'cannot read sessions to organize' do
      expect(ability).to_not be_able_to(:read, 'organizer_sessions')
    end

    it 'cannot read organizer reports' do
      expect(ability).to_not be_able_to(:read, 'organizer_reports')
    end

    it 'cannot read accepted sessions reports' do
      expect(ability).to_not be_able_to(:read, 'accepted_sessions')
    end

    it 'cannot read sessions to review' do
      expect(ability).to_not be_able_to(:read, 'reviewer_sessions')
    end

    context 'if reviewer' do
      let(:reviewer) { FactoryBot.build(:reviewer, user: user, conference: conference) }
      let(:ability) { Ability.new(user, conference, nil, reviewer) }

      it 'can accept reviewer invitation if invited' do
        expect(ability).to_not be_able_to(:manage, 'accept_reviewers')

        reviewer.state = 'invited'
        expect(ability).to be_able_to(:manage, 'accept_reviewers')
      end

      it 'can reject reviewer invitation if invited' do
        expect(ability).to_not be_able_to(:manage, 'reject_reviewers')

        reviewer.state = 'invited'
        expect(ability).to be_able_to(:manage, 'reject_reviewers')
      end
    end
  end

  context '- admin' do
    before(:each) do
      user.add_role 'admin'
    end

    it 'can manage all' do
      expect(ability).to be_able_to(:manage, :all)
    end
  end

  context '- author' do
    before(:each) do
      user.add_role 'author'
    end

    it_should_behave_like 'all users'

    it 'cannot manage reviewer' do
      expect(ability).to_not be_able_to(:manage, Reviewer)
    end

    it 'cannot read organizers' do
      expect(ability).to_not be_able_to(:read, Organizer)
    end

    it 'cannot read reviews' do
      expect(ability).to_not be_able_to(:read, Review)
      expect(ability).to_not be_able_to(:read, FinalReview)
      expect(ability).to_not be_able_to(:read, EarlyReview)
    end

    context 'index early reviews of' do
      let(:session) { FactoryBot.build(:session, conference: conference) }

      it 'his sessions as first author is allowed' do
        session.author = user
        expect(ability).to_not be_able_to(:index, EarlyReview)
        expect(ability).to be_able_to(:index, EarlyReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:index, EarlyReview)
        expect(ability).to be_able_to(:index, EarlyReview, session)
      end

      it 'his sessions as second author is allowed' do
        session.second_author = user
        expect(ability).to_not be_able_to(:index, EarlyReview)
        expect(ability).to be_able_to(:index, EarlyReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:index, EarlyReview)
        expect(ability).to be_able_to(:index, EarlyReview, session)
      end

      it 'other peoples sessions is forbidden' do
        expect(ability).to_not be_able_to(:index, EarlyReview)
        expect(ability).to_not be_able_to(:index, EarlyReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:index, EarlyReview)
        expect(ability).to_not be_able_to(:index, EarlyReview, session)
      end
    end

    context 'index final reviews of' do
      let(:session) { FactoryBot.build(:session, review_decision: FactoryBot.build(:review_decision, published: true)) }

      it 'his sessions as first author is allowed' do
        session.author = user
        expect(ability).to_not be_able_to(:index, FinalReview)
        expect(ability).to be_able_to(:index, FinalReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:index, FinalReview)
        expect(ability).to be_able_to(:index, FinalReview, session)
      end

      it 'his sessions as second author is allowed' do
        session.second_author = user
        expect(ability).to_not be_able_to(:index, FinalReview)
        expect(ability).to be_able_to(:index, FinalReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:index, FinalReview)
        expect(ability).to be_able_to(:index, FinalReview, session)
      end

      it 'his sessions if review has been published' do
        session.author = user
        expect(ability).to be_able_to(:index, FinalReview, session)
        session.review_decision.published = false
        expect(ability).to_not be_able_to(:index, FinalReview, session)
      end

      it 'other peoples sessions is forbidden' do
        expect(ability).to_not be_able_to(:index, FinalReview)
        expect(ability).to_not be_able_to(:index, FinalReview, session)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:index, FinalReview)
        expect(ability).to_not be_able_to(:index, FinalReview, session)
      end
    end

    it 'cannot read reviews listing' do
      expect(ability).to_not be_able_to(:read, 'reviews_listing')
    end

    it 'cannot read sessions to organize' do
      expect(ability).to_not be_able_to(:read, 'organizer_sessions')
    end

    it 'cannot read organizers reports' do
      expect(ability).to_not be_able_to(:read, 'organizer_reports')
    end

    it 'cannot read accepted sessions reports' do
      expect(ability).to_not be_able_to(:read, 'accepted_sessions')
    end

    it 'cannot read sessions to review' do
      expect(ability).to_not be_able_to(:read, 'reviewer_sessions')
    end

    describe 'with regards to create sessions:' do
      it 'can in submissions phase' do
        conference.expects(:in_submission_phase?).returns(true)
        expect(ability).to be_able_to(:create, Session)
      end

      it 'can in submissions phase with existing submissions' do
        user.save!
        FactoryBot.create(:session, author: user, conference: conference)

        conference.expects(:in_submission_phase?).returns(true)

        expect(ability).to be_able_to(:create, Session)
      end

      context 'for conference with submission limits' do
        before(:each) do
          conference.submission_limit = 1
        end
        it 'can in submissions phase and with less submissions than limit' do
          conference.expects(:in_submission_phase?).returns(true)
          expect(ability).to be_able_to(:create, Session)
        end

        it 'cannot in submissions phase and already at the limit of submissions' do
          user.save!
          FactoryBot.create(:session, author: user, conference: conference)

          conference.expects(:in_submission_phase?).returns(true)

          expect(ability).to_not be_able_to(:create, Session)
        end
      end

      it 'cannot out of submissions phase' do
        conference.expects(:in_submission_phase?).returns(false)
        expect(ability).to_not be_able_to(:create, Session)
      end

      it 'overides admin privileges to check for deadlines' do
        user.add_role('admin')
        conference.stubs(:in_submission_phase?).returns(false)

        expect(ability).to_not be_able_to(:create, Session)
        expect(ability).to_not be_able_to(:new, Session)
      end
    end

    describe 'can update session if:' do
      let(:session) { FactoryBot.build(:session, conference: conference) }
      before(:each) do
        conference.stubs(:in_submission_phase?).returns(true)
      end

      it '- user is first author' do
        expect(ability).to_not be_able_to(:update, session)
        session.author = user
        expect(ability).to be_able_to(:update, session)
      end

      it '- user is second author' do
        expect(ability).to_not be_able_to(:update, session)
        session.second_author = user
        expect(ability).to be_able_to(:update, session)
      end

      it '- in submissions phase' do
        session.author = user
        conference.expects(:in_submission_phase?).returns(true)
        expect(ability).to be_able_to(:update, session)
      end

      it '- out of submissions phase cant update' do
        session.author = user
        conference.expects(:in_submission_phase?).returns(false)
        expect(ability).to_not be_able_to(:update, session)
      end

      it '- session on current conference' do
        session.author = user
        expect(ability).to be_able_to(:update, session)
        session.conference = FactoryBot.create(:conference)
        expect(ability).to_not be_able_to(:update, session)
      end
    end

    context 'can cancel session if:' do
      let(:track) { FactoryBot.create(:track, conference: conference) }
      let(:session) { FactoryBot.build(:session, conference: conference, track: track) }
      let(:ability) { Ability.new(user, conference, session) }

      it '- user is author' do
        expect(ability).to_not be_able_to(:cancel, session)

        session.author = user
        expect(ability).to be_able_to(:cancel, session)
      end

      it '- session is not already cancelled' do
        user.save
        session.author = user
        expect(ability).to be_able_to(:cancel, session)

        session.cancel

        expect(ability).to_not be_able_to(:cancel, session)
      end
    end

    describe 'can confirm session if:' do
      let(:another_user) { FactoryBot.build(:user) }
      let(:session) do
        FactoryBot.build(:session,
                         author: user,
                         state: 'pending_confirmation',
                         review_decision: FactoryBot.build(:review_decision))
      end
      before(:each) do
        conference.stubs(:in_author_confirmation_phase?).returns(true)
      end

      it '- user is first author' do
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')

        session.author = another_user
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')
      end

      it '- user is second author' do
        session.author = another_user
        session.second_author = user

        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')
      end

      it '- session is pending confirmation' do
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')

        session.state = 'rejected'
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')
      end

      it '- session has a review decision' do
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')

        session.review_decision = nil
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')
      end

      it '- outside of author confirmation phase cant confirm' do
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')

        conference.expects(:in_author_confirmation_phase?).returns(false)
        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')
      end
    end

    describe 'can withdraw session if:' do
      let(:another_user) { FactoryBot.build(:user) }
      let(:session) do
        FactoryBot.build(:session,
                         author: user,
                         state: 'pending_confirmation',
                         review_decision: FactoryBot.build(:review_decision))
      end
      before(:each) do
        conference.stubs(:in_author_confirmation_phase?).returns(true)
      end

      it '- user is first author' do
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'withdraw_sessions')

        session.author = another_user
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')
      end

      it '- user is second author' do
        session.author = another_user
        session.second_author = user

        expect(ability).to_not be_able_to(:manage, 'confirm_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'confirm_sessions')
      end

      it '- session is pending confirmation' do
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'withdraw_sessions')

        session.state = 'rejected'
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')
      end

      it '- session has a review decision' do
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'withdraw_sessions')

        session.review_decision = nil
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')
      end

      it '- outside of author confirmation phase cant withdraw' do
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:manage, 'withdraw_sessions')

        conference.expects(:in_author_confirmation_phase?).returns(false)
        expect(ability).to_not be_able_to(:manage, 'withdraw_sessions')
      end
    end

    context 'create review feedback' do
      let(:session) do
        FactoryBot.build(:session,
                         author: user,
                         conference: conference,
                         review_decision: FactoryBot.build(:review_decision, published: true))
      end
      let(:sessions) { [session] }
      before(:each) do
        user.stubs(:sessions_for_conference).with(conference).returns(sessions)
        sessions.stubs(:includes).with(:review_decision).returns(sessions)
      end

      it 'with a session for the conference is allowed' do
        expect(ability).to be_able_to(:create, ReviewFeedback)
      end

      it 'with a valid and a cancelled proposal for the conference is allowed' do
        cancelled_session = FactoryBot.build(:session,
                                             author: user, conference: conference, state: 'cancelled')
        sessions = [session, cancelled_session]
        user.stubs(:sessions_for_conference).with(conference).returns(sessions)
        sessions.stubs(:includes).with(:review_decision).returns(sessions)

        expect(ability).to be_able_to(:create, ReviewFeedback)
      end

      it 'any review if session does not have a review decision' do
        session.review_decision = nil
        expect(ability).to_not be_able_to(:create, ReviewFeedback)
      end

      it 'any review if review has been published' do
        session.review_decision.published = false
        expect(ability).to_not be_able_to(:create, ReviewFeedback)
      end

      it 'is not author' do
        sessions = []
        user.stubs(:sessions_for_conference).with(conference).returns(sessions)
        sessions.stubs(:includes).with(:review_decision).returns([])

        expect(ability).to_not be_able_to(:create, ReviewFeedback)
      end
    end
  end

  context '- organizer' do
    before(:each) do
      user.add_role 'organizer'
      Conference.stubs(:current).returns(conference)
      Organizer.stubs(:user_organizing_conference?).with(user, conference).returns(true)
    end

    it_should_behave_like 'all users'

    it 'can manage reviewer' do
      expect(ability).to be_able_to(:manage, Reviewer)
    end

    it 'cannot read organizers' do
      expect(ability).to_not be_able_to(:read, Organizer)
    end

    it 'can show reviews' do
      expect(ability).to be_able_to(:show, Review)
      expect(ability).to be_able_to(:show, FinalReview)
      expect(ability).to be_able_to(:show, EarlyReview)
    end

    it 'can index review decisions' do
      expect(ability).to be_able_to(:index, ReviewDecision)
    end

    it 'can read reviews listing' do
      expect(ability).to be_able_to(:read, 'reviews_listing')
      expect(ability).to_not be_able_to(:reviewer, 'reviews_listing')
    end

    it 'can read sessions to organize' do
      expect(ability).to be_able_to(:read, 'organizer_sessions')
    end

    it 'can read organizer report' do
      expect(ability).to be_able_to(:read, 'organizer_reports')
    end

    it 'can read accepted sessions reports' do
      expect(ability).to be_able_to(:read, 'accepted_sessions')
    end

    it 'cannot read sessions to review' do
      expect(ability).to_not be_able_to(:read, 'reviewer_sessions')
    end

    context 'organizer index reviews of' do
      let(:track) { FactoryBot.build(:track, conference: conference) }
      let(:session) { FactoryBot.build(:session, conference: conference, track: track) }

      it 'session on organizers track is allowed' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to_not be_able_to(:organizer, FinalReview)
        expect(ability).to_not be_able_to(:organizer, EarlyReview)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:organizer, FinalReview)
        expect(ability).to be_able_to(:organizer, EarlyReview)
      end

      it 'session outside of organizers track is forbidden' do
        expect(ability).to_not be_able_to(:organizer, FinalReview)
        expect(ability).to_not be_able_to(:organizer, EarlyReview)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:organizer, FinalReview)
        expect(ability).to_not be_able_to(:organizer, EarlyReview)
      end
    end

    context 'can cancel session if:' do
      let(:track) { FactoryBot.create(:track, conference: conference) }
      let(:session) { FactoryBot.build(:session, conference: conference, track: track) }

      it '- session on organizers track' do
        expect(ability).to_not be_able_to(:cancel, session)

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:cancel, session)
      end

      it '- session is not already cancelled' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:cancel, session)
        session.cancel
        expect(ability).to_not be_able_to(:cancel, session)
      end
    end

    context 'can create review decision if:' do
      let(:track) { FactoryBot.create(:track, conference: conference) }
      let(:session) { FactoryBot.build(:session, conference: conference, track: track) }
      before(:each) do
        session.reviewing
        Timecop.freeze(conference.review_deadline + 1.day)
      end
      after(:each) do
        Timecop.return
      end

      it '- session on organizers track' do
        expect(ability).to_not be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        user.stubs(:organized_tracks).with(conference).returns([session.track])

        expect(ability).to be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference)
        expect(ability).to be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)
      end

      it '- after review deadline' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])

        Timecop.freeze(conference.review_deadline + 1.second) do
          expect(ability).to be_able_to(:create, ReviewDecision, session)

          ability = Ability.new(user, conference, session)
          expect(ability).to be_able_to(:create, ReviewDecision)
        end
      end

      it '- before review deadline cant create review decision' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])
        Timecop.freeze(conference.review_deadline) do
          expect(ability).to_not be_able_to(:create, ReviewDecision, session)

          ability = Ability.new(user, conference, session)
          expect(ability).to_not be_able_to(:create, ReviewDecision)
        end
      end

      it '- overrides admin privileges to check if session on organizers track' do
        user.add_role('admin')

        expect(ability).to_not be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference)
        expect(ability).to be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)
      end

      it '- session is in review' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, ReviewDecision)

        session.reject
        expect(ability).to_not be_able_to(:create, ReviewDecision)

        ability = Ability.new(user, conference)
        expect(ability).to_not be_able_to(:create, ReviewDecision, session)
        expect(ability).to_not be_able_to(:create, ReviewDecision)
      end
    end

    context 'can edit review decision session' do
      let(:track) { FactoryBot.create(:track, conference: conference) }
      let(:session) { FactoryBot.build(:session, conference: conference, track: track) }
      before(:each) do
        session.reviewing
        Timecop.freeze(conference.review_deadline + 1.day)
      end
      after(:each) do
        Timecop.return
      end

      it 'if session on organizers track' do
        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        FactoryBot.build(:organizer, track: session.track, user: user)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference)
        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)
      end

      it 'overrides admin privileges to check if session on organizers track' do
        user.add_role('admin')

        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        FactoryBot.build(:organizer, track: session.track, user: user)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference)
        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)
      end

      it 'if session was not confirmed by author' do
        session.tentatively_accept
        session.accept

        FactoryBot.build(:organizer, track: session.track, user: user)
        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)
      end

      it 'unless session was rejected by author' do
        session.tentatively_accept

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:update, ReviewDecision, session)

        session.reject
        session.author_agreement = true
        session.save

        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
      end

      it 'unless session was accepted by author' do
        session.tentatively_accept

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:update, ReviewDecision, session)

        session.accept
        session.author_agreement = true
        session.save

        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
      end

      it 'if session has a review decision' do
        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to_not be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)
      end

      it 'if session is rejected' do
        session.reject

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:update, ReviewDecision)
      end

      it 'if session is tentatively accepted' do
        session.tentatively_accept

        user.stubs(:organized_tracks).with(conference).returns([session.track])
        expect(ability).to be_able_to(:update, ReviewDecision, session)
        expect(ability).to_not be_able_to(:update, ReviewDecision)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:update, ReviewDecision)
      end

      it 'after review deadline' do
        session.tentatively_accept

        Timecop.freeze(conference.review_deadline + 1.second) do
          user.stubs(:organized_tracks).with(conference).returns([session.track])
          expect(ability).to be_able_to(:update, ReviewDecision, session)

          ability = Ability.new(user, conference, session)
          expect(ability).to be_able_to(:update, ReviewDecision)
        end
      end

      it 'before review deadline cant update review decision' do
        session.tentatively_accept

        Timecop.freeze(conference.review_deadline) do
          user.stubs(:organized_tracks).with(conference).returns([session.track])
          expect(ability).to_not be_able_to(:update, ReviewDecision, session)

          ability = Ability.new(user, conference, session)
          expect(ability).to_not be_able_to(:update, ReviewDecision)
        end
      end
    end
  end

  context '- reviewer' do
    before(:each) do
      user.add_role 'reviewer'
      Reviewer.stubs(:user_reviewing_conference?).returns(true)
      # TODO: review this
      reviewer = FactoryBot.build(:reviewer, user: user, conference: conference, state: 'accepted')
      track = FactoryBot.build(:track, conference: conference)
      audience_level = FactoryBot.build(:audience_level, conference: conference)
      reviewer.preferences.build(accepted: true, track: track, audience_level: audience_level)
    end

    it_should_behave_like 'all users'

    it 'cannot read organizers' do
      expect(ability).to_not be_able_to(:read, Organizer)
    end

    it 'cannot read other reviewers' do
      expect(ability).to_not be_able_to(:read, Reviewer)
    end

    it 'cannot read organizers sessions' do
      expect(ability).to_not be_able_to(:read, 'organizer_sessions')
    end

    it 'cannot read organizers reports' do
      expect(ability).to_not be_able_to(:read, 'organizer_reports')
    end

    it 'cannot read accepted sessions reports' do
      expect(ability).to_not be_able_to(:read, 'accepted_sessions')
    end

    it 'can read sessions to review' do
      expect(ability).to be_able_to(:read, 'reviewer_sessions')
    end

    it 'can read reviews listing' do
      expect(ability).to be_able_to(:read, 'reviews_listing')
      expect(ability).to be_able_to(:reviewer, 'reviews_listing')
    end

    it 'cannot index all reviews of any session' do
      expect(ability).to_not be_able_to(:index, Review)
      expect(ability).to_not be_able_to(:index, FinalReview)
      expect(ability).to_not be_able_to(:index, EarlyReview)
    end

    it 'cannot index all organizer reviews of any session' do
      expect(ability).to_not be_able_to(:organizer, Review)
      expect(ability).to_not be_able_to(:organizer, FinalReview)
      expect(ability).to_not be_able_to(:organizer, EarlyReview)
    end

    it 'can show own early reviews' do
      review = FactoryBot.build(:early_review)
      expect(ability).to_not be_able_to(:show, review)
      review.reviewer = user
      expect(ability).to be_able_to(:show, review)
    end

    it 'can show own final reviews' do
      review = FactoryBot.build(:final_review)
      expect(ability).to_not be_able_to(:show, review)
      review.reviewer = user
      expect(ability).to be_able_to(:show, review)
    end

    context 'can create a new final review if:' do
      let(:session) { FactoryBot.build(:session) }
      before(:each) do
        Session.stubs(:for_reviewer).with(user, conference).returns([session])
        conference.stubs(:in_final_review_phase?).returns(true)
      end

      it 'has a session available to add the final review to' do
        expect(ability).to_not be_able_to(:create, FinalReview)
        expect(ability).to_not be_able_to(:create, FinalReview, nil)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, FinalReview)
        expect(ability).to be_able_to(:create, FinalReview, nil)
        expect(ability).to be_able_to(:create, FinalReview, session)
      end

      it 'before final review deadline' do
        conference.expects(:in_final_review_phase?).returns(true)
        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, FinalReview)
        expect(ability).to be_able_to(:create, FinalReview, nil)
        expect(ability).to be_able_to(:create, FinalReview, session)
      end

      it 'after final review deadline cant review' do
        conference.stubs(:in_final_review_phase?).returns(false)
        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:create, FinalReview)
        expect(ability).to_not be_able_to(:create, FinalReview, nil)
        expect(ability).to_not be_able_to(:create, FinalReview, session)
      end

      it 'overrides admin privileges to check if session available' do
        user.add_role('admin')

        expect(ability).to_not be_able_to(:create, FinalReview)
        expect(ability).to_not be_able_to(:create, FinalReview, nil)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, FinalReview)
        expect(ability).to be_able_to(:create, FinalReview, nil)
        expect(ability).to be_able_to(:create, FinalReview, session)
      end
    end

    context 'can create a new early review if:' do
      let(:session) { FactoryBot.build(:session) }
      before(:each) do
        Session.stubs(:for_reviewer).with(user, conference).returns([session])
        conference.stubs(:in_early_review_phase?).returns(true)
      end

      it 'has a session available to add the early review to' do
        expect(ability).to_not be_able_to(:create, EarlyReview)
        expect(ability).to_not be_able_to(:create, EarlyReview, nil)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, EarlyReview)
        expect(ability).to be_able_to(:create, EarlyReview, nil)
        expect(ability).to be_able_to(:create, EarlyReview, session)
      end

      it 'before early review deadline' do
        conference.expects(:in_early_review_phase?).returns(true)
        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, EarlyReview)
        expect(ability).to be_able_to(:create, EarlyReview, nil)
        expect(ability).to be_able_to(:create, EarlyReview, session)
      end

      it 'after early review deadline cant review' do
        conference.stubs(:in_early_review_phase?).returns(false)
        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:create, EarlyReview)
        expect(ability).to_not be_able_to(:create, EarlyReview, nil)
        expect(ability).to_not be_able_to(:create, EarlyReview, session)
      end

      it 'overrides admin privileges to check if session available' do
        user.add_role('admin')

        expect(ability).to_not be_able_to(:create, EarlyReview)
        expect(ability).to_not be_able_to(:create, EarlyReview, nil)

        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, EarlyReview)
        expect(ability).to be_able_to(:create, EarlyReview, nil)
        expect(ability).to be_able_to(:create, EarlyReview, session)
      end
    end
  end

  context '- voter' do
    let(:vote) { FactoryBot.build(:vote) }
    let(:session) { vote.session }
    before(:each) do
      user.add_role 'voter'
    end

    it_should_behave_like 'all users'

    it 'can read votes' do
      expect(ability).to be_able_to(:read, Vote)
    end

    context 'can create a new vote if:' do
      before(:each) do
        conference.stubs(:in_voting_phase?).returns(true)
      end

      it 'within limit for conference with session' do
        Vote.expects(:within_limit?).with(user, conference).twice.returns(true, false)
        expect(ability).to be_able_to(:create, Vote, session)
        expect(ability).to_not be_able_to(:create, Vote, session)
      end

      it 'within limit for conference without session' do
        Vote.expects(:within_limit?).with(user, conference).twice.returns(true, false)
        expect(ability).to be_able_to(:create, Vote)
        expect(ability).to_not be_able_to(:create, Vote)
      end

      it 'user is not first author' do
        expect(ability).to be_able_to(:create, Vote, session)
        expect(ability).to be_able_to(:create, Vote)
        session.author = user
        expect(ability).to_not be_able_to(:create, Vote, session)
        expect(ability).to be_able_to(:create, Vote)
      end

      it 'user is not second author' do
        expect(ability).to be_able_to(:create, Vote, session)
        expect(ability).to be_able_to(:create, Vote)
        session.second_author = user
        expect(ability).to_not be_able_to(:create, Vote, session)
        expect(ability).to be_able_to(:create, Vote)
      end

      it 'before voting deadline' do
        conference.stubs(:in_voting_phase?).returns(true)
        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:create, Vote)
        expect(ability).to be_able_to(:create, Vote, nil)
        expect(ability).to be_able_to(:create, Vote, session)
      end

      it 'after voting deadline cant vote' do
        conference.stubs(:in_voting_phase?).returns(false)
        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:create, Vote)
        expect(ability).to_not be_able_to(:create, Vote, nil)
        expect(ability).to_not be_able_to(:create, Vote, session)
      end
    end

    context 'can destroy votes if:' do
      let(:vote) { FactoryBot.build(:vote, user: user) }
      before do
        conference.stubs(:in_voting_phase?).returns(true)
      end

      it 'user is voter' do
        expect(ability).to be_able_to(:destroy, vote)
        vote.user_id = 0
        expect(ability).to_not be_able_to(:destroy, vote)
      end

      it 'before voting deadline' do
        conference.stubs(:in_voting_phase?).returns(true)
        ability = Ability.new(user, conference, session)
        expect(ability).to be_able_to(:destroy, vote)
      end

      it 'after voting deadline cant destroy vote' do
        conference.stubs(:in_voting_phase?).returns(false)
        ability = Ability.new(user, conference, session)
        expect(ability).to_not be_able_to(:destroy, vote)
      end
    end
  end
end
