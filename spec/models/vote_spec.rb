# frozen_string_literal: true

require 'spec_helper'

describe Vote, type: :model do
  describe 'validations' do
    should_validate_existence_of :conference, :session, :user

    describe 'uniqueness' do
      before { FactoryBot.create(:vote) }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:session_id, :conference_id) }
    end

    describe 'session' do
      it 'matches the conference' do
        conference = FactoryBot.create(:conference)
        session = FactoryBot.create(:session, conference: FactoryBot.create(:conference))
        vote = FactoryBot.build(:vote, session: session, conference: conference)
        expect(vote).not_to be_valid
        expect(vote.errors[:session_id]).to include(I18n.t('errors.messages.same_conference'))
      end
    end

    describe 'user' do
      let(:second_author) { FactoryBot.create(:author) }
      let(:session) { FactoryBot.create(:session) }
      let(:vote) { FactoryBot.build(:vote, session: session) }

      it 'is not author for voted session' do
        vote.user = session.author
        expect(vote).not_to be_valid
        expect(vote.errors[:user_id]).to include(I18n.t('activerecord.errors.models.vote.author'))
      end

      it 'is not second author for voted session' do
        session.second_author = second_author
        vote.user = second_author
        expect(vote).not_to be_valid
        expect(vote.errors[:user_id]).to include(I18n.t('activerecord.errors.models.vote.author'))
      end

      it 'is voter' do
        vote.user.remove_role(:voter)
        expect(vote).not_to be_valid
        expect(vote.errors[:user_id]).to include(I18n.t('activerecord.errors.models.vote.voter'))
      end
    end

    describe 'limit' do
      let(:user) { FactoryBot.create(:voter) }

      before { FactoryBot.create_list(:vote, Vote::VOTE_LIMIT, user: user) }

      it "should only allow #{Vote::VOTE_LIMIT} votes for given conference" do
        vote = FactoryBot.build(:vote, user: user)
        expect(vote).not_to be_valid
        expect(vote.errors[:base]).to include(I18n.t('activerecord.errors.models.vote.limit_reached', count: Vote::VOTE_LIMIT))
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :session }
    it { is_expected.to belong_to :conference }
  end

  describe '#within_limit?' do
    subject { Vote }

    let(:voter) { FactoryBot.create(:voter) }
    let(:conference) do
      FactoryBot.create(:conference).tap { |c| Conference.stubs(:current).returns(c) }
    end

    context 'without user' do
      it { is_expected.not_to be_within_limit(nil, conference) }
    end

    context 'without conference' do
      it { is_expected.not_to be_within_limit(voter, nil) }
    end

    context 'without voting' do
      it { is_expected.to be_within_limit(voter, conference) }
    end

    context 'when past vote limit' do
      before { FactoryBot.create_list(:vote, Vote::VOTE_LIMIT, user: voter, conference: conference) }

      it { is_expected.not_to be_within_limit(voter, conference) }
    end
  end
end
