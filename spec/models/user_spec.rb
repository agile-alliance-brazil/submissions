# frozen_string_literal: true

require 'spec_helper'

describe User, type: :model do
  context 'trimming' do
    it_should_trim_attributes User, :first_name, :last_name, :username,
                              :email, :phone, :city, :organization,
                              :website_url, :bio, :twitter_username
    it 'trims state if country is Brazil' do
      user = FactoryBot.build(:user, state: '  Rio de Janeiro  ', country: 'BR')
      expect(user).to be_valid
      expect(user.state).to eq('Rio de Janeiro')
    end
  end

  context 'before validations' do
    it 'trims @ from twitter username if present' do
      user = FactoryBot.build(:user, twitter_username: '@dtsato')
      expect(user).to be_valid
      expect(user.twitter_username).to eq('dtsato')

      user = FactoryBot.build(:user, twitter_username: '  @dtsato  ')
      expect(user).to be_valid
      expect(user.twitter_username).to eq('dtsato')
    end

    it 'does not change twitter username if @ is not present' do
      user = FactoryBot.build(:user, twitter_username: 'dtsato')
      expect(user).to be_valid
      expect(user.twitter_username).to eq('dtsato')

      user = FactoryBot.build(:user, twitter_username: '  dtsato  ')
      expect(user).to be_valid
      expect(user.twitter_username).to eq('dtsato')
    end

    it 'removes state for non brazilians' do
      user = FactoryBot.build(:user, country: 'US', state: 'Illinois').tap { |u| u.add_role('author') }
      expect(user).to be_valid
      expect(user.state).to be_empty
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }

    context 'brazilians' do
      subject { FactoryBot.build(:user, country: 'BR') }

      it { is_expected.not_to validate_presence_of :state }
    end

    context 'author' do
      subject { FactoryBot.build(:user).tap { |u| u.add_role('author') } }

      it { is_expected.to validate_presence_of :phone }
      it { is_expected.to validate_presence_of :country }
      it { is_expected.to validate_presence_of :city }
      it { is_expected.to validate_presence_of :bio }

      it { is_expected.to validate_length_of(:phone).is_at_most(100) }
      it { is_expected.to validate_length_of(:bio).is_at_most(1600) }
      it { is_expected.to validate_length_of(:city).is_at_most(100) }

      it { is_expected.to allow_value('1234-2345').for(:phone) }
      it { is_expected.to allow_value('+55 11 5555 2234').for(:phone) }
      it { is_expected.to allow_value('+1 (304) 543.3333').for(:phone) }
      it { is_expected.to allow_value('07753423456').for(:phone) }
      it { is_expected.not_to allow_value('a').for(:phone) }
      it { is_expected.not_to allow_value('1234-bfd').for(:phone) }
      it { is_expected.not_to allow_value(')(*&^%$@!').for(:phone) }
      it { is_expected.not_to allow_value('[=+]').for(:phone) }

      context 'brazilians' do
        subject { FactoryBot.build(:user, country: 'BR').tap { |u| u.add_role('author') } }

        it { is_expected.to validate_presence_of :state }
      end
    end

    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { is_expected.to validate_length_of(:password).is_at_least(3).is_at_most(30) }
    it { is_expected.to validate_length_of(:email).is_at_least(6).is_at_most(100) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:organization).is_at_most(100) }
    it { is_expected.to validate_length_of(:website_url).is_at_most(100) }

    it { is_expected.to allow_value('dtsato').for(:username) }
    it { is_expected.to allow_value('123').for(:username) }
    it { is_expected.to allow_value('a b c').for(:username) }
    it { is_expected.to allow_value('danilo.sato').for(:username) }
    it { is_expected.to allow_value('dt-sato@dt_sato.com').for(:username) }
    it { is_expected.not_to allow_value('dt$at0').for(:username) }
    it { is_expected.not_to allow_value('<>/?').for(:username) }
    it { is_expected.not_to allow_value(')(*&^%$@!').for(:username) }
    it { is_expected.not_to allow_value('[=+]').for(:username) }

    it { is_expected.to allow_value('user@domain.com.br').for(:email) }
    it { is_expected.to allow_value('test_user.name@a.co.uk').for(:email) }
    it { is_expected.not_to allow_value('a').for(:email) }
    it { is_expected.not_to allow_value('a@').for(:email) }
    it { is_expected.not_to allow_value('a@a').for(:email) }
    it { is_expected.not_to allow_value('@12.com').for(:email) }

    describe 'uniqueness' do
      subject { FactoryBot.create(:user, country: 'BR') }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message(I18n.t('activerecord.errors.models.user.attributes.email.taken')) }
      it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    end

    it { is_expected.to validate_confirmation_of(:password) }

    it "validates that username doesn't change" do
      user = FactoryBot.create(:user)
      user.username = 'new_username'
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include(I18n.t('errors.messages.constant'))
    end
  end

  describe 'associations' do
    it { is_expected.to have_many :sessions }
    it { is_expected.to have_many :organizers }
    it { is_expected.to have_many(:all_organized_tracks).through(:organizers) }
    it { is_expected.to have_many :reviewers }
    it { is_expected.to have_many :reviews }
    it { is_expected.to have_many :early_reviews }
    it { is_expected.to have_many :final_reviews }
    it { is_expected.to have_many :votes }
    it { is_expected.to have_many(:voted_sessions).through(:votes) }
    it { is_expected.to have_many :comments }

    describe 'organized tracks for conference' do
      it 'narrows tracks based on conference' do
        organizer = FactoryBot.create(:organizer)
        user = organizer.user
        old_conference = FactoryBot.create(:conference)
        old_track = FactoryBot.create(:track, conference: old_conference)
        FactoryBot.create(:organizer, user: user, track: old_track, conference: old_conference)

        expect(user.organized_tracks(organizer.conference)).to eq([organizer.track])
      end
    end

    describe 'sessions for conference' do
      it 'narrows sessions based on conference for user' do
        session = FactoryBot.create(:session)
        FactoryBot.create(:session)
        user = session.author

        expect(user.sessions_for_conference(session.conference)).to eq([session])
      end

      it 'returns session where user is second author' do
        session = FactoryBot.create(:session)
        user = session.author
        user.add_role :author

        another_session = FactoryBot.create(:session, second_author: user)

        expect(user.sessions_for_conference(session.conference)).to eq([session, another_session])
      end
    end

    describe '#has_approved_session?' do
      before do
        @conference = FactoryBot.create(:conference)
        FactoryBot.create(:session_type, conference: @conference, title: 'session_types.lightning_talk.title')
        FactoryBot.create(:session_type, conference: @conference, title: 'session_types.talk.title')
        @track = FactoryBot.create(:track, conference: @conference)
        @audience_level = FactoryBot.create(:audience_level, conference: @conference)
        @lightning_talk = @conference.session_types.find(&:lightning_talk?)
        @non_lightning_talk = @conference.session_types.find { |st| !st.lightning_talk? }
      end

      it 'does not have approved long sessions if never submited' do
        user = FactoryBot.build(:user)
        expect(user).not_to have_approved_session(@conference)
      end

      it 'does not have approved long sessions if accepted was on another conference' do
        user = FactoryBot.build(:user)

        FactoryBot.build(:session, author: user, conference: @conference)

        expect(user).not_to have_approved_session(@conference)
      end

      it 'has approved long sessions if accepted was lightning talk' do
        user = FactoryBot.create(:user)
        user.add_role :author
        session = FactoryBot.create(:session, author: user, session_type: @lightning_talk,
                                              duration_mins: 50, state: 'accepted',
                                              conference: @conference,
                                              track: @track,
                                              audience_level: @audience_level)

        expect(user).to have_approved_session(session.conference)
      end

      it 'has approved long sessions if accepted was not lightning talk' do
        user = FactoryBot.create(:user)
        user.add_role :author
        session = FactoryBot.create(:session, author: user, session_type: @non_lightning_talk,
                                              state: 'accepted',
                                              conference: @conference,
                                              track: @track,
                                              audience_level: @audience_level)

        expect(user).to have_approved_session(session.conference)
      end

      it 'has approved sessions as second author' do
        user = FactoryBot.create(:user)
        user.add_role :author
        session = FactoryBot.create(:session, second_author: user, state: 'accepted')

        expect(user).to have_approved_session(session.conference)
      end
    end

    describe 'user preferences' do
      it 'returns reviewer preferences based on conference' do
        preference = FactoryBot.create(:preference)
        reviewer = preference.reviewer
        user = reviewer.user
        old_conference = FactoryBot.create(:conference)
        FactoryBot.create(:preference,
                          reviewer: FactoryBot.create(:reviewer, user: user, conference: old_conference),
                          audience_level: FactoryBot.create(:audience_level, conference: old_conference))

        expect(user.preferences(reviewer.conference)).to eq([preference])
      end
    end
  end

  context 'authorization' do
    it 'has role of author when wants to submit' do
      expect(User.new(wants_to_submit: '0')).not_to be_author
      expect(User.new(wants_to_submit: '1')).to be_author
    end
  end

  it 'provides full name' do
    user = User.new(first_name: 'Danilo', last_name: 'Sato')
    expect(user.full_name).to eq('Danilo Sato')
  end

  it 'provides in_brazil?' do
    user = User.new
    expect(user).not_to be_in_brazil
    user.country = 'BR'
    expect(user).to be_in_brazil
  end

  it 'retrieves the actual reviewer' do
    user = FactoryBot.create(:user)
    reviewer = FactoryBot.create(:reviewer, user: user)
    expect(user.reviewer_for(reviewer.conference).id).to eq(reviewer.id)
  end

  it "does not retrieve if there isn't an actual reviewer" do
    user = FactoryBot.create(:user)
    other_conference = FactoryBot.create(:conference)
    FactoryBot.create(:reviewer, user: user, conference: other_conference)

    expect(user.reviewer_for(FactoryBot.create(:conference))).to be_nil
  end

  it 'overides to_param with username' do
    user = FactoryBot.create(:user, username: 'danilo.sato 1990@2')
    expect(user.to_param.ends_with?('-danilo-sato-1990-2')).to be true

    user.username = nil
    expect(user.to_param.ends_with?('-danilo-sato-1990-2')).to be false
  end

  it "has 'pt-BR' as default locale" do
    user = FactoryBot.build(:user)
    expect(user.default_locale).to eq('pt-BR')
  end

  describe 'after_save' do
    context 'when there is no current conference' do
      context 'on create' do
        subject(:user) { FactoryBot.create(:user) }
        it { expect(user.user_conferences).to be_empty }
      end

      context 'on update' do
        subject(:user) { FactoryBot.create(:user) }
        before { user.update first_name: 'John Doe' }
        it { expect(user.user_conferences).to be_empty }
      end
    end

    context 'when there is no current conference' do
      let!(:conference) { FactoryBot.create(:conference) }

      context 'on create' do
        subject(:user) { FactoryBot.create(:user) }

        it 'registers profile as reviewed for current conference' do
          expect(user.user_conferences).to have(1).items
          expect(user.user_conferences.first.conference_id).to eq(conference.id)
          expect(user.user_conferences.first.profile_reviewed).to be(true)
        end
      end

      context 'on update' do
        subject(:user) { FactoryBot.create(:user) }
        before { user.update first_name: 'John Doe' }
        it 'registers profile as reviewed for current conference' do
          expect(user.user_conferences).to have(1).items
          expect(user.user_conferences.first.conference_id).to eq(conference.id)
          expect(user.user_conferences.first.profile_reviewed).to be(true)
        end
      end
    end
  end
end
