# frozen_string_literal: true

require 'spec_helper'

describe Session, type: :model do
  it_should_trim_attributes Session, :title, :summary, :description, :mechanics, :benefits,
                            :target_audience, :second_author_username, :experience

  context 'associations' do
    it { should belong_to(:author).class_name('User') }
    it { should belong_to(:second_author).class_name('User') }
    it { should belong_to :track }
    it { should belong_to :session_type }
    it { should belong_to :audience_level }
    it { should belong_to :conference }

    it { should have_many(:comments).dependent(:destroy) }

    it { should have_many :early_reviews }
    it { should have_many :final_reviews }
    it { should have_one  :review_decision }
    it { should have_many :votes }

    context 'second author username' do
      subject { FactoryBot.build(:session) }
      it_should_behave_like 'virtual username attribute', :second_author
    end
  end

  context 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :summary }
    it { should validate_presence_of :description }
    it { should validate_presence_of :benefits }
    it { should validate_presence_of :target_audience }
    it { should validate_presence_of :experience }
    it { should validate_presence_of :duration_mins }
    it { should validate_presence_of :language }
    it { should validate_presence_of :track_id }
    it { should validate_presence_of :session_type_id }
    it { should validate_presence_of :audience_level_id }

    it { should validate_inclusion_of(:language).in_array(['en', 'pt-BR']) }

    should_validate_existence_of :conference, :author, :track, :session_type, :audience_level

    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_length_of(:target_audience).is_at_most(200) }
    it { should validate_length_of(:summary).is_at_most(800) }
    it { should validate_length_of(:description).is_at_most(2400) }
    it { should validate_length_of(:benefits).is_at_most(400) }
    it { should validate_length_of(:experience).is_at_most(400) }

    context 'with mismatched conferences' do
      let(:conference) { FactoryBot.create(:conference) }
      let(:other_conference) { FactoryBot.create(:conference) }
      context 'track' do
        it 'should match the conference' do
          other_track = FactoryBot.create(:track, conference: other_conference)

          session = FactoryBot.build(:session, track: other_track, conference: conference)

          expect(session).to_not be_valid
          expect(session.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end

      context 'audience level' do
        it 'should match the conference' do
          other_level = FactoryBot.create(:audience_level, conference: other_conference)

          session = FactoryBot.build(:session, audience_level: other_level, conference: conference)

          expect(session).to_not be_valid
          expect(session.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end

      context 'session type' do
        it 'should match the conference' do
          other_type = FactoryBot.create(:session_type, conference: other_conference)

          session = FactoryBot.build(:session, session_type: other_type, conference: conference)

          expect(session).to_not be_valid
          expect(session.errors[:session_type_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end
    end

    context 'mechanics' do
      context 'workshops' do
        subject { FactoryBot.build(:session) }
        before { subject.session_type = FactoryBot.create(:session_type, title: 'session_types.workshop.title', conference: subject.conference) }

        it { should validate_presence_of(:mechanics) }
        it { should validate_length_of(:mechanics).is_at_most(2400) }
      end

      context 'hands on' do
        subject { FactoryBot.build(:session) }
        before { subject.session_type = FactoryBot.create(:session_type, title: 'session_types.hands_on.title', conference: subject.conference) }

        it { should validate_presence_of(:mechanics) }
        it { should validate_length_of(:mechanics).is_at_most(2400) }
      end
    end

    context 'second author' do
      before(:each) do
        @session = FactoryBot.build(:session)
      end

      it 'should be a valid user' do
        @session.second_author_username = 'invalid_username'
        expect(@session).to_not be_valid
        expect(@session.errors[:second_author_username]).to include(I18n.t('activerecord.errors.messages.existence'))
      end

      it 'should not be the same as first author' do
        @session.second_author_username = @session.author.username
        expect(@session).to_not be_valid
        expect(@session.errors[:second_author_username]).to include(I18n.t('errors.messages.same_author'))
      end

      it 'should be author' do
        guest = FactoryBot.create(:user)
        @session.second_author_username = guest.username
        expect(@session).to_not be_valid
        expect(@session.errors[:second_author_username]).to include(I18n.t('errors.messages.incomplete'))
      end
    end

    it 'should only accept valid durations for session type' do
      @session = FactoryBot.build(:session)
      @session.session_type.valid_durations = [25, 50]
      @session.duration_mins = 25
      expect(@session).to be_valid
      @session.duration_mins = 50
      expect(@session).to be_valid
      @session.duration_mins = 80
      expect(@session).to_not be_valid
      @session.duration_mins = 110
      expect(@session).to_not be_valid
    end

    it "should validate that author doesn't change" do
      session = FactoryBot.create(:session)
      session.author_id = FactoryBot.create(:user).id
      expect(session).to_not be_valid
      expect(session.errors[:author_id]).to include(I18n.t('errors.messages.constant'))
    end

    context 'confirming attendance:' do
      it 'should validate that author agreement was accepted on acceptance' do
        session = FactoryBot.build(:session)
        session.reviewing
        session.tentatively_accept
        expect(session.update_attributes(state_event: 'accept', author_agreement: '0')).to be false
        expect(session.errors[:author_agreement]).to include(I18n.t('errors.messages.accepted'))
      end

      it 'should validate that author agreement was accepted on withdraw' do
        session = FactoryBot.build(:session)
        session.reviewing
        session.tentatively_accept
        expect(session.update_attributes(state_event: 'reject', author_agreement: '0')).to be false
        expect(session.errors[:author_agreement]).to include(I18n.t('errors.messages.accepted'))
      end

      it 'should be valid when author agreement was accepted on acceptance' do
        session = FactoryBot.build(:session)
        session.reviewing
        session.tentatively_accept
        updated = session.update_attributes(state_event: 'accept', author_agreement: '1')
        expect(session.errors).to be_empty
        expect(updated).to be true
      end

      it 'should validate that author agreement was accepted on withdraw' do
        session = FactoryBot.build(:session)
        session.reviewing
        session.tentatively_accept
        updated = session.update_attributes(state_event: 'reject', author_agreement: '1')
        expect(session.errors).to be_empty
        expect(updated).to be true
      end
    end

    it 'should validate that there is at least 1 keyword' do
      session = FactoryBot.build(:session, keyword_list: %w[a])
      expect(session).to be_valid
      session.keyword_list = %w[]
      expect(session).to_not be_valid
      expect(session.errors[:keyword_list]).to include(I18n.t('activerecord.errors.models.session.attributes.keyword_list.too_short', count: 1))
    end

    it 'should validate that there are a maximum of 10 keywords' do
      session = FactoryBot.build(:session, keyword_list: %w[a b c d e f g h i j])
      expect(session).to be_valid
      session.keyword_list = %w[a b c d e f g h i j k]
      expect(session).to_not be_valid
      expect(session.errors[:keyword_list]).to include(I18n.t('activerecord.errors.models.session.attributes.keyword_list.too_long', count: 10))
    end

    it 'should validate that there are a maximum of 10 keywords in comma-separated list' do
      session = FactoryBot.build(:session, keyword_list: 'a, b, c, d, e, f, g, h, i, j')
      expect(session).to be_valid
      session.keyword_list = 'a, b, c, d, e, f, g, h, i, j, k'
      expect(session).to_not be_valid
      expect(session.errors[:keyword_list]).to include(I18n.t('activerecord.errors.models.session.attributes.keyword_list.too_long', count: 10))
    end

    it 'should validate session limit for first author' do
      session = FactoryBot.build(:session)
      session.conference.submission_limit = 1
      c = stub()
      session.author.stubs(:sessions_for_conference).with(session.conference).returns(c)
      c.stubs(:count).returns(0)
      expect(session).to be_valid
      c.stubs(:count).returns(1)
      expect(session).to_not be_valid
      expect(session.errors[:author]).to include(I18n.t('errors.activerecord.models.session.attributes.submission_limit', max: 1))
    end

    it 'should validate session limit for second author' do
      session = FactoryBot.build(:session)
      session.conference.submission_limit = 1
      c = stub()
      session.second_author = FactoryBot.build(:author)
      session.second_author.stubs(:sessions_for_conference).with(session.conference).returns(c)
      c.stubs(:count).returns(0)
      expect(session).to be_valid
      c.stubs(:count).returns(1)
      expect(session).to_not be_valid
      expect(session.errors[:second_author]).to include(I18n.t('errors.activerecord.models.session.attributes.submission_limit', max: 1))
    end
  end

  context 'named scopes' do
    context 'for_reviewer / for_review_in' do
      before(:each) do
        # TODO: review this
        @reviewer = FactoryBot.create(:reviewer)
        @user = @reviewer.user
        @conference = @reviewer.conference
        @track = FactoryBot.create(:track, conference: @conference)
        @audience_level = FactoryBot.create(:audience_level, conference: @conference)

        @conference.presubmissions_deadline = Time.zone.now
        @session = FactoryBot.create(:session, conference: @conference, track: @track, audience_level: @audience_level, created_at: @conference.presubmissions_deadline - 1.day)
      end

      context 'during early review phase' do
        before(:each) do
          @conference.stubs(:in_early_review_phase?).returns(true)
          @conference.stubs(:in_final_review_phase?).returns(false)

          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
        end

        it 'should bring only one session unreviewed' do
          expect(Session.for_reviewer(@user, @conference).count).to eq(1 => 1)
        end

        it 'if reviewed multiple times, it should only be returned once' do
          FactoryBot.create(:early_review, session: @session)
          FactoryBot.create(:early_review, session: @session)
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'should only be returned once even if reviewed multiple times' do
          FactoryBot.create(:early_review, session: @session)
          FactoryBot.create(:early_review, session: @session)
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'should not be returned if already reviewed by user' do
          FactoryBot.create(:early_review, session: @session, reviewer: @user)
          expect(Session.for_reviewer(@user, @conference)).to eq([])
        end

        context 'early review deadline' do
          it 'should be returned if submitted at the early review deadline' do
            session = FactoryBot.create(:session, conference: @conference, track: @track, audience_level: @audience_level, created_at: @conference.presubmissions_deadline)
            expect(Session.for_reviewer(@user, @conference)).to include(session)
          end

          it 'should be returned if submitted 3 hours past the early review deadline' do
            session = FactoryBot.create(:session, conference: @conference, track: @track, audience_level: @audience_level, created_at: @conference.presubmissions_deadline + 3.hours)
            expect(Session.for_reviewer(@user, @conference)).to include(session)
          end

          it 'should not be returned if submitted after 3 hours past the early review deadline' do
            session = FactoryBot.create(:session, conference: @conference, track: @track, audience_level: @audience_level, created_at: @conference.presubmissions_deadline + 3.hours + 1.second)
            expect(Session.for_reviewer(@user, @conference)).to_not include(session)
          end
        end
      end

      context 'during final review phase' do
        before(:each) do
          @conference.stubs(:in_early_review_phase?).returns(false)
          @conference.stubs(:in_final_review_phase?).returns(true)

          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
        end

        it 'should bring only one session unreviewed' do
          expect(Session.for_reviewer(@user, @conference).count).to eq(1 => 1)
        end

        it 'should only be returned once if reviewed multiple times' do
          FactoryBot.create(:final_review, session: @session)
          FactoryBot.create(:final_review, session: @session)
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'should not be returned if already reviewed by user' do
          FactoryBot.create(:final_review, session: @session, reviewer: @user)
          expect(Session.for_reviewer(@user, @conference)).to eq([])
        end

        it 'should not be returned if already reviewed by user and another user' do
          FactoryBot.create(:final_review, session: @session)
          FactoryBot.create(:final_review, session: @session, reviewer: @user)
          expect(Session.for_reviewer(@user, @conference)).to eq([])
        end

        it 'should be returned if reviewed by user during early review' do
          FactoryBot.create(:early_review, session: @session, reviewer: @user)
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'should not be returned if already reviewed 3 times' do
          FactoryBot.create_list(:final_review, 3, session: @session)
          expect(Session.for_reviewer(@user, @conference)).to eq([])
        end
      end

      context 'preferences' do
        it 'if user has no preferences, no sessions to review' do
          expect(Session.for_reviewer(@user, @conference)).to be_empty
        end

        it 'one preference' do
          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'multiple preferences' do
          track = FactoryBot.create(:track, conference: @conference)
          session = FactoryBot.create(:session, conference: @conference, track: track, audience_level: @audience_level)

          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
          FactoryBot.create(:preference, reviewer: @reviewer, track: track, audience_level: @audience_level)

          expect((Session.for_reviewer(@user, @conference) - [session, @session])).to be_empty
        end
      end

      context 'cancelled' do
        before(:each) do
          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
        end

        it 'non-cancelled should be returned' do
          expect(Session.for_reviewer(@user, @conference)).to eq([@session])
        end

        it 'cancelled should not be returned' do
          @session.cancel
          expect(Session.for_reviewer(@user, @conference)).to be_empty
        end
      end

      context 'author' do
        before(:each) do
          FactoryBot.create(:preference, reviewer: @reviewer, track: @track, audience_level: @audience_level)
        end

        it 'if reviewer is first author, should not be returned' do
          FactoryBot.create(:reviewer, user: @session.author)

          expect(Session.for_reviewer(@session.author, @conference)).to be_empty
        end

        it 'if reviewer is second author, should not be returned' do
          second_author = FactoryBot.create(:author)
          @session.update_attributes!(second_author_username: second_author.username)

          expect(Session.for_reviewer(second_author, @conference)).to be_empty
        end
      end
    end

    describe '.active' do
      let!(:session) { FactoryBot.create :session }
      let!(:cancelled_session) { FactoryBot.create :session, state: :cancelled }

      it { expect(Session.active).to eq [session] }
    end
  end

  SessionType.all_titles.each do |title|
    it "should determine if it is #{title}" do
      session = FactoryBot.build(:session)
      session.session_type.title = "session_types.#{title}.title"
      expect(session.send(:"#{title}?")).to be true
      session.session_type.title = 'session_types.other.title'
      expect(session.send(:"#{title}?")).to be false
    end
  end

  it 'should overide to_param with session title' do
    session = FactoryBot.create(:session, title: 'refatoração e código limpo: na prática.')
    expect(session.to_param.ends_with?('-refatoracao-e-codigo-limpo-na-pratica')).to be true

    session.title = nil
    expect(session.to_param.ends_with?('-refatoracao-e-codigo-limpo-na-pratica')).to be false
  end

  context 'authors' do
    it 'should provide main author' do
      session = FactoryBot.build(:session)
      expect(session.authors).to eq([session.author])
    end

    it 'should provide second author if available' do
      user = FactoryBot.build(:user)
      user.add_role(:author)
      session = FactoryBot.build(:session, second_author: user)
      expect(session.authors).to eq([session.author, user])
    end

    it 'should be empty if no authors' do
      session = FactoryBot.build(:session)
      session.author = nil
      expect(session.authors).to be_empty
    end

    it 'should state that first author is author' do
      user = FactoryBot.build(:user)
      user.add_role(:author)

      session = FactoryBot.build(:session, author: user)
      expect(session.is_author?(user)).to be true
      session.author = nil
      expect(session.is_author?(user)).to be false
    end

    it 'should state that second author is author' do
      user = FactoryBot.build(:user)
      user.add_role(:author)

      session = FactoryBot.build(:session, second_author: user)
      expect(session.is_author?(user)).to be true
      session.second_author = nil
      expect(session.is_author?(user)).to be false
    end
  end

  context 'state machine' do
    before(:each) do
      @session = FactoryBot.build(:session)
    end

    context 'State: created' do
      it 'should be the initial state' do
        expect(@session).to be_created
      end

      it 'should allow reviewing' do
        expect(@session.reviewing).to be true
        expect(@session).to_not be_created
        expect(@session).to be_in_review
      end

      it 'should allow cancel' do
        expect(@session.cancel).to be true
        expect(@session).to_not be_created
        expect(@session).to be_cancelled
      end

      it 'should not allow tentatively accept' do
        expect(@session.tentatively_accept).to be false
      end

      it 'should not allow accepting' do
        expect(@session.accept).to be false
      end

      it 'should not allow rejecting' do
        expect(@session.reject).to be false
      end
    end

    context 'State: in review' do
      before(:each) do
        @session.reviewing
        expect(@session).to be_in_review
      end

      it 'should allow reviewing again' do
        expect(@session.reviewing).to be true
        expect(@session).to be_in_review
      end

      it 'should allow cancel' do
        expect(@session.cancel).to be true
        expect(@session).to_not be_in_review
        expect(@session).to be_cancelled
      end

      it 'should allow tentatively accept' do
        expect(@session.tentatively_accept).to be true
        expect(@session).to_not be_in_review
        expect(@session).to be_pending_confirmation
      end

      it 'should not allow accepting' do
        expect(@session.accept).to be false
      end

      it 'should allow rejecting' do
        expect(@session.reject).to be true
        expect(@session).to_not be_in_review
        expect(@session).to be_rejected
      end
    end

    context 'State: cancelled' do
      before(:each) do
        @session.cancel
        expect(@session).to be_cancelled
      end

      it 'should not allow reviewing' do
        expect(@session.reviewing).to be false
      end

      it 'should not allow cancelling' do
        expect(@session.cancel).to be false
      end

      it 'should not allow tentatively accept' do
        expect(@session.tentatively_accept).to be false
      end

      it 'should not allow accepting' do
        expect(@session.accept).to be false
      end

      it 'should not allow rejecting' do
        expect(@session.reject).to be false
      end
    end

    context 'State: pending confirmation' do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        expect(@session).to be_pending_confirmation
      end

      it 'should not allow reviewing' do
        expect(@session.reviewing).to be false
      end

      it 'should not allow cancelling' do
        expect(@session.cancel).to be false
      end

      it 'should not allow tentatively accept' do
        expect(@session.tentatively_accept).to be false
      end

      it 'should allow accepting' do
        expect(@session.accept).to be true
        expect(@session).to_not be_pending_confirmation
        expect(@session).to be_accepted
      end

      it 'should allow rejecting' do
        expect(@session.reject).to be true
        expect(@session).to_not be_pending_confirmation
        expect(@session).to be_rejected
      end
    end

    context 'State: accepted' do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        @session.accept
        expect(@session).to be_accepted
      end

      it 'should not allow reviewing' do
        expect(@session.reviewing).to be false
      end

      it 'should not allow cancelling' do
        expect(@session.cancel).to be false
      end

      it 'should not allow tentatively accept' do
        expect(@session.tentatively_accept).to be false
      end

      it 'should not allow accepting' do
        expect(@session.accept).to be false
      end

      it 'should not allow rejecting' do
        expect(@session.reject).to be false
      end
    end

    context 'State: rejected' do
      before(:each) do
        @session.reviewing
        @session.reject
        expect(@session).to be_rejected
      end

      it 'should not allow reviewing' do
        expect(@session.reviewing).to be false
      end

      it 'should not allow cancelling' do
        expect(@session.cancel).to be false
      end

      it 'should allow tentatively accept' do
        expect(@session.tentatively_accept).to be true
        expect(@session).to_not be_rejected
        expect(@session).to be_pending_confirmation
      end

      it 'should not allow accepting' do
        expect(@session.accept).to be false
      end

      it 'should not allow rejecting' do
        expect(@session.reject).to be false
      end
    end
  end
end
