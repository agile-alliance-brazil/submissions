# frozen_string_literal: true

require 'spec_helper'

describe Session, type: :model do
  it_should_trim_attributes Session, :title, :summary, :description, :mechanics, :benefits,
                            :target_audience, :second_author_username, :experience

  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:second_author).class_name('User') }
    it { is_expected.to belong_to :track }
    it { is_expected.to belong_to :session_type }
    it { is_expected.to belong_to :audience_level }
    it { is_expected.to belong_to :conference }

    it { is_expected.to have_many(:comments).dependent(:destroy) }

    it { is_expected.to have_many :early_reviews }
    it { is_expected.to have_many :final_reviews }
    it { is_expected.to have_one  :review_decision }
    it { is_expected.to have_many :votes }

    describe 'second author username' do
      subject { FactoryBot.build(:session) }

      it_behaves_like 'virtual username attribute', :second_author
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :summary }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :benefits }
    it { is_expected.to validate_presence_of :target_audience }
    it { is_expected.to validate_presence_of :experience }
    it { is_expected.to validate_presence_of :duration_mins }
    it { is_expected.to validate_presence_of :language }
    it { is_expected.to validate_presence_of :track_id }
    it { is_expected.to validate_presence_of :session_type_id }
    it { is_expected.to validate_presence_of :audience_level_id }

    it { is_expected.to validate_inclusion_of(:language).in_array(%w[en pt-BR]) }

    should_validate_existence_of :conference, :author, :track, :session_type, :audience_level

    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_length_of(:target_audience).is_at_most(200) }
    it { is_expected.to validate_length_of(:summary).is_at_most(800) }
    it { is_expected.to validate_length_of(:description).is_at_most(2400) }
    it { is_expected.to validate_length_of(:benefits).is_at_most(400) }
    it { is_expected.to validate_length_of(:experience).is_at_most(400) }

    context 'with mismatched conferences' do
      let(:conference) { FactoryBot.create(:conference) }
      let(:other_conference) { FactoryBot.create(:conference) }

      describe 'track' do
        it 'matches the conference' do
          other_track = FactoryBot.create(:track, conference: other_conference)

          session = FactoryBot.build(:session, track: other_track, conference: conference)

          expect(session).not_to be_valid
          expect(session.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end

      describe 'audience level' do
        it 'matches the conference' do
          other_level = FactoryBot.create(:audience_level, conference: other_conference)

          session = FactoryBot.build(:session, audience_level: other_level, conference: conference)

          expect(session).not_to be_valid
          expect(session.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end

      describe 'session type' do
        it 'matches the conference' do
          other_type = FactoryBot.create(:session_type, conference: other_conference)

          session = FactoryBot.build(:session, session_type: other_type, conference: conference)

          expect(session).not_to be_valid
          expect(session.errors[:session_type_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end
    end

    describe 'mechanics' do
      subject(:session) { FactoryBot.build(:session) }

      describe 'workshops' do
        before { session.session_type = FactoryBot.create(:session_type, title: 'session_types.workshop.title', conference: session.conference) }

        it { is_expected.to validate_presence_of(:mechanics) }
        it { is_expected.to validate_length_of(:mechanics).is_at_most(2400) }
      end

      describe 'hands on' do
        before { session.session_type = FactoryBot.create(:session_type, title: 'session_types.hands_on.title', conference: session.conference) }

        it { is_expected.to validate_presence_of(:mechanics) }
        it { is_expected.to validate_length_of(:mechanics).is_at_most(2400) }
      end
    end

    describe 'second author' do
      subject(:session) { FactoryBot.build(:session) }

      it 'is a valid user' do
        session.second_author_username = 'invalid_username'
        expect(session).not_to be_valid
        expect(session.errors[:second_author_username]).to include(I18n.t('activerecord.errors.messages.existence'))
      end

      it 'is not the same as first author' do
        session.second_author_username = session.author.username
        expect(session).not_to be_valid
        expect(session.errors[:second_author_username]).to include(I18n.t('errors.messages.same_author'))
      end

      it 'is author' do
        guest = FactoryBot.create(:user)
        session.second_author_username = guest.username
        expect(session).not_to be_valid
        expect(session.errors[:second_author_username]).to include(I18n.t('errors.messages.incomplete'))
      end
    end

    describe 'valid durations' do
      subject(:session) { FactoryBot.build(:session) }

      let(:valid_durations) { [25, 50] }

      before { session.session_type.valid_durations = valid_durations }

      [25, 50].each do |valid_duration|
        it "is valid for #{valid_duration}" do
          session.duration_mins = valid_duration
          expect(session).to be_valid
        end
      end

      [80, 110].each do |invalid_duration|
        it "is invalid for #{invalid_duration}" do
          session.duration_mins = invalid_duration
          expect(session).not_to be_valid
        end
      end
    end

    it "validates that author doesn't change" do
      session = FactoryBot.create(:session)
      session.author_id = FactoryBot.create(:user).id
      expect(session).not_to be_valid
      expect(session.errors[:author_id]).to include(I18n.t('errors.messages.constant'))
    end

    describe 'confirming attendance:' do
      subject(:session) { FactoryBot.build(:session) }

      before do
        session.reviewing
        session.tentatively_accept
      end

      it 'validates that author agreement was accepted on acceptance' do
        expect(session.update(state_event: 'accept', author_agreement: '0')).to be false
        expect(session.errors[:author_agreement]).to include(I18n.t('errors.messages.accepted'))
      end

      it 'stops withdrawal without author agreement' do
        expect(session.update(state_event: 'reject', author_agreement: '0')).to be false
        expect(session.errors[:author_agreement]).to include(I18n.t('errors.messages.accepted'))
      end

      it 'is valid when author agreement was accepted on acceptance' do
        updated = session.update(state_event: 'accept', author_agreement: '1')
        expect(session.errors).to be_empty
        expect(updated).to be true
      end

      it 'validates that author agreement was accepted on withdraw' do
        updated = session.update(state_event: 'reject', author_agreement: '1')
        expect(session.errors).to be_empty
        expect(updated).to be true
      end
    end

    it 'validates that there is at least 1 keyword' do
      session = FactoryBot.build(:session, keyword_list: %w[a])
      expect(session).to be_valid
      session.keyword_list = %w[]
      expect(session).not_to be_valid
      expect(session.errors[:keyword_list]).to include(I18n.t('activerecord.errors.models.session.attributes.keyword_list.too_short', count: 1))
    end

    describe 'maximum keywords' do
      subject(:session) { FactoryBot.build(:session, keyword_list: %w[a b c d e f g h i j]) }

      it { is_expected.to be_valid }
      it 'is invalid with more keywords' do
        session.keyword_list = %w[a b c d e f g h i j k]
        expect(session).not_to be_valid
      end

      context 'with limited conference keywords' do
        before { session.conference.tag_limit = 5 }

        it { is_expected.not_to be_valid }
        it 'is valid with conferece limit keywords' do
          session.keyword_list = %w[a b c d e]
          expect(session).to be_valid
        end
      end
    end

    it 'validates that there are a maximum of 10 keywords in comma-separated list' do
      session = FactoryBot.build(:session, keyword_list: 'a, b, c, d, e, f, g, h, i, j')
      expect(session).to be_valid
      session.keyword_list = 'a, b, c, d, e, f, g, h, i, j, k'
      expect(session).not_to be_valid
      expect(session.errors[:keyword_list]).to include(I18n.t('activerecord.errors.models.session.attributes.keyword_list.too_long', count: 10))
    end

    describe 'session limit' do
      subject(:session) { FactoryBot.build(:session) }

      let(:conference_sessions) { stub }

      before do
        session.conference.submission_limit = 1

        conference_sessions.stubs(:active).returns(conference_sessions)
      end

      context 'when checking first author' do
        before { session.author.stubs(:sessions_for_conference).with(session.conference).returns(conference_sessions) }

        it 'is valid when under limit' do
          conference_sessions.stubs(:count).returns(0)
          expect(session).to be_valid
        end

        it 'is not valid when equal or above limit' do
          conference_sessions.stubs(:count).returns(1)
          expect(session).not_to be_valid
          expect(session.errors[:author]).to include(I18n.t('activerecord.errors.models.session.attributes.authors.submission_limit', max: 1))
        end
      end

      context 'when checking second author' do
        before do
          session.second_author = FactoryBot.build(:author)
          session.second_author.stubs(:sessions_for_conference).with(session.conference).returns(conference_sessions)
        end

        it 'is valid when under limit' do
          conference_sessions.stubs(:count).returns(0)
          expect(session).to be_valid
        end

        it 'is not valid when equal or above limit' do
          conference_sessions.stubs(:count).returns(1)
          expect(session).not_to be_valid
          expect(session.errors[:second_author]).to include(I18n.t('activerecord.errors.models.session.attributes.authors.submission_limit', max: 1))
        end
      end
    end
  end

  describe 'named scopes' do
    describe 'for_reviewer / for_review_in' do
      subject(:session) { FactoryBot.build(:session, conference: conference, track: track, audience_level: audience_level, created_at: conference.presubmissions_deadline - 1.day) }

      let(:conference) { FactoryBot.create(:conference).tap { |c| c.presubmissions_deadline = Time.zone.now } }
      let(:track) { FactoryBot.create(:track, conference: conference) }
      let(:audience_level) { FactoryBot.create(:audience_level, conference: conference) }
      let(:reviewer) { FactoryBot.create(:reviewer, conference: conference) }
      let(:user) { reviewer.user }

      context 'when in early review phase' do
        before do
          conference.stubs(:in_early_review_phase?).returns(true)
          conference.stubs(:in_final_review_phase?).returns(false)

          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)

          session.save!
        end

        it 'brings only one session unreviewed' do
          expect(Session.for_reviewer(user, conference).count).to eq(session.id => 1)
        end

        it 'if reviewed multiple times, it should only be returned once' do
          FactoryBot.create(:early_review, session: session)
          FactoryBot.create(:early_review, session: session)
          expect(Session.for_reviewer(user, conference)).to eq([session])
        end

        it 'is not returned if already reviewed by user' do
          FactoryBot.create(:early_review, session: session, reviewer: user)
          expect(Session.for_reviewer(user, conference)).to eq([])
        end

        describe 'early review deadline' do
          it 'is returned if submitted at the early review deadline' do
            session = FactoryBot.create(:session, conference: conference, track: track, audience_level: audience_level, created_at: conference.presubmissions_deadline)
            expect(Session.for_reviewer(user, conference)).to include(session)
          end

          it 'is returned if submitted 3 hours past the early review deadline' do
            session = FactoryBot.create(:session, conference: conference, track: track, audience_level: audience_level, created_at: conference.presubmissions_deadline + 3.hours)
            expect(Session.for_reviewer(user, conference)).to include(session)
          end

          it 'is not returned if submitted after 3 hours past the early review deadline' do
            session = FactoryBot.create(:session, conference: conference, track: track, audience_level: audience_level, created_at: conference.presubmissions_deadline + 3.hours + 1.second)
            expect(Session.for_reviewer(user, conference)).not_to include(session)
          end
        end
      end

      context 'when in final review phase' do
        before do
          conference.stubs(:in_early_review_phase?).returns(false)
          conference.stubs(:in_final_review_phase?).returns(true)

          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)

          session.save!
        end

        it 'brings only one session unreviewed' do
          expect(Session.for_reviewer(user, conference).count).to eq(session.id => 1)
        end

        it 'onlies be returned once if reviewed multiple times' do
          FactoryBot.create(:final_review, session: session)
          FactoryBot.create(:final_review, session: session)
          expect(Session.for_reviewer(user, conference)).to eq([session])
        end

        it 'is not returned if already reviewed by user' do
          FactoryBot.create(:final_review, session: session, reviewer: user)
          expect(Session.for_reviewer(user, conference)).to eq([])
        end

        it 'is not returned if already reviewed by user and another user' do
          FactoryBot.create(:final_review, session: session)
          FactoryBot.create(:final_review, session: session, reviewer: user)
          expect(Session.for_reviewer(user, conference)).to eq([])
        end

        it 'is returned if reviewed by user during early review' do
          FactoryBot.create(:early_review, session: session, reviewer: user)
          expect(Session.for_reviewer(user, conference)).to eq([session])
        end

        it 'is not returned if already reviewed 3 times' do
          FactoryBot.create_list(:final_review, 3, session: session)
          expect(Session.for_reviewer(user, conference)).to eq([])
        end
      end

      describe 'preferences' do
        before { session.save! }

        it 'if user has no preferences, no sessions to review' do
          expect(Session.for_reviewer(user, conference)).to be_empty
        end

        it 'one preference' do
          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)
          expect(Session.for_reviewer(user, conference)).to eq([session])
        end

        it 'multiple preferences' do
          other_track = FactoryBot.create(:track, conference: conference)
          other_session = FactoryBot.create(:session, conference: conference, track: other_track, audience_level: audience_level)

          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)
          FactoryBot.create(:preference, reviewer: reviewer, track: other_track, audience_level: audience_level)

          expect((Session.for_reviewer(user, conference) - [session, other_session])).to be_empty
        end
      end

      describe 'cancelled' do
        before do
          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)

          session.save!
        end

        it 'non-cancelled should be returned' do
          expect(Session.for_reviewer(user, conference)).to eq([session])
        end

        it 'cancelled should not be returned' do
          session.cancel
          expect(Session.for_reviewer(user, conference)).to be_empty
        end
      end

      describe 'author' do
        before do
          FactoryBot.create(:preference, reviewer: reviewer, track: track, audience_level: audience_level)
        end

        it 'if reviewer is first author, should not be returned' do
          FactoryBot.create(:reviewer, user: session.author)

          expect(Session.for_reviewer(session.author, conference)).to be_empty
        end

        it 'if reviewer is second author, should not be returned' do
          second_author = FactoryBot.create(:author)
          session.update!(second_author_username: second_author.username)

          expect(Session.for_reviewer(second_author, conference)).to be_empty
        end
      end
    end

    describe '.active' do
      let!(:session) { FactoryBot.create :session }

      it 'ignores cancelled sessions' do
        FactoryBot.create :session, state: :cancelled

        expect(Session.active).to eq [session]
      end
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

  it 'overides to_param with session title' do
    session = FactoryBot.create(:session, title: 'refatoração e código limpo: na prática.')
    expect(session.to_param.ends_with?('-refatoracao-e-codigo-limpo-na-pratica')).to be true

    session.title = nil
    expect(session.to_param.ends_with?('-refatoracao-e-codigo-limpo-na-pratica')).to be false
  end

  describe 'authors' do
    it 'provides main author' do
      session = FactoryBot.build(:session)
      expect(session.authors).to eq([session.author])
    end

    it 'provides second author if available' do
      user = FactoryBot.build(:user)
      user.add_role(:author)
      session = FactoryBot.build(:session, second_author: user)
      expect(session.authors).to eq([session.author, user])
    end

    it 'is empty if no authors' do
      session = FactoryBot.build(:session)
      session.author = nil
      expect(session.authors).to be_empty
    end

    describe 'is_author?' do
      subject(:session) { FactoryBot.build(:session, author: user) }

      let(:user) { FactoryBot.build(:user) }
      let(:other_user) { FactoryBot.build(:user) }

      before do
        user.add_role(:author)
        other_user.add_role(:author)
      end

      context 'with only one author' do
        it 'is true for first author' do
          expect(session.is_author?(user)).to be true
        end
        it 'is false for other users' do
          expect(session.is_author?(other_user)).to be false
        end
      end

      context 'with two authors' do
        before { session.second_author = other_user }

        it 'is true for second author' do
          expect(session.is_author?(other_user)).to be true
        end

        it 'is false for other users' do
          expect(session.is_author?(FactoryBot.build(:user))).to be false
        end
      end
    end
  end

  describe 'state machine' do
    subject(:session) { FactoryBot.build(:session) }

    context 'when state: created' do
      it 'is the initial state' do
        expect(session).to be_created
      end

      it 'allows reviewing' do
        expect(session.reviewing).to be true
        expect(session).not_to be_created
        expect(session).to be_in_review
      end

      it 'allows cancel' do
        expect(session.cancel).to be true
        expect(session).not_to be_created
        expect(session).to be_cancelled
      end

      it 'does not allow tentatively accept' do
        expect(session.tentatively_accept).to be false
      end

      it 'does not allow accepting' do
        expect(session.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(session.reject).to be false
      end
    end

    context 'when state: in review' do
      before do
        session.reviewing
        expect(session).to be_in_review
      end

      it 'allows reviewing again' do
        expect(session.reviewing).to be true
        expect(session).to be_in_review
      end

      it 'allows cancel' do
        expect(session.cancel).to be true
        expect(session).not_to be_in_review
        expect(session).to be_cancelled
      end

      it 'allows tentatively accept' do
        expect(session.tentatively_accept).to be true
        expect(session).not_to be_in_review
        expect(session).to be_pending_confirmation
      end

      it 'does not allow accepting' do
        expect(session.accept).to be false
      end

      it 'allows rejecting' do
        expect(session.reject).to be true
        expect(session).not_to be_in_review
        expect(session).to be_rejected
      end
    end

    context 'when in state: cancelled' do
      before do
        session.cancel
        expect(session).to be_cancelled
      end

      it 'does not allow reviewing' do
        expect(session.reviewing).to be false
      end

      it 'does not allow cancelling' do
        expect(session.cancel).to be false
      end

      it 'does not allow tentatively accept' do
        expect(session.tentatively_accept).to be false
      end

      it 'does not allow accepting' do
        expect(session.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(session.reject).to be false
      end
    end

    context 'when in state: pending confirmation' do
      before do
        session.reviewing
        session.tentatively_accept
        expect(session).to be_pending_confirmation
      end

      it 'does not allow reviewing' do
        expect(session.reviewing).to be false
      end

      it 'does not allow cancelling' do
        expect(session.cancel).to be false
      end

      it 'does not allow tentatively accept' do
        expect(session.tentatively_accept).to be false
      end

      it 'allows accepting' do
        expect(session.accept).to be true
        expect(session).not_to be_pending_confirmation
        expect(session).to be_accepted
      end

      it 'allows rejecting' do
        expect(session.reject).to be true
        expect(session).not_to be_pending_confirmation
        expect(session).to be_rejected
      end
    end

    context 'when in state: accepted' do
      before do
        session.reviewing
        session.tentatively_accept
        session.accept
        expect(session).to be_accepted
      end

      it 'does not allow reviewing' do
        expect(session.reviewing).to be false
      end

      it 'does not allow cancelling' do
        expect(session.cancel).to be false
      end

      it 'does not allow tentatively accept' do
        expect(session.tentatively_accept).to be false
      end

      it 'does not allow accepting' do
        expect(session.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(session.reject).to be false
      end
    end

    context 'when in state: rejected' do
      before do
        session.reviewing
        session.reject
        expect(session).to be_rejected
      end

      it 'does not allow reviewing' do
        expect(session.reviewing).to be false
      end

      it 'does not allow cancelling' do
        expect(session.cancel).to be false
      end

      it 'allows tentatively accept' do
        expect(session.tentatively_accept).to be true
        expect(session).not_to be_rejected
        expect(session).to be_pending_confirmation
      end

      it 'does not allow accepting' do
        expect(session.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(session.reject).to be false
      end
    end
  end
end
