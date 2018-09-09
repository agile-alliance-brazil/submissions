# frozen_string_literal: true

require 'spec_helper'

describe Organizer, type: :model do
  it_should_trim_attributes Organizer, :user_username

  describe 'validations' do
    it { is_expected.to validate_presence_of :track_id }

    describe 'uniqueness' do
      before { FactoryBot.create(:organizer) }

      it { is_expected.to validate_uniqueness_of(:track_id).scoped_to(:conference_id, :user_id).with_message(I18n.t('activerecord.errors.models.organizer.attributes.track_id.taken')) }
    end

    should_validate_existence_of :user, :conference
    should_validate_existence_of :track

    describe 'user' do
      it 'is a valid user' do
        organizer = FactoryBot.build(:organizer)
        organizer.user_username = 'invalid_username'
        expect(organizer).not_to be_valid
        expect(organizer.errors[:user_username]).to include(I18n.t('activerecord.errors.messages.existence'))
      end
    end

    describe 'track' do
      it 'matches the conference' do
        track = FactoryBot.create(:track)
        other_conference = FactoryBot.create(:conference)
        organizer = FactoryBot.build(:organizer, track: track, conference: other_conference)
        expect(organizer).not_to be_valid
        expect(organizer.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :track }
    it { is_expected.to belong_to :conference }

    describe 'organizer username' do
      subject { FactoryBot.build(:organizer) }

      it_behaves_like 'virtual username attribute', :user
    end
  end

  # TODO: Fix example lengths
  # rubocop:disable RSpec/ExampleLength
  shared_examples_for 'organizer role' do
    it 'makes given user organizer role after created' do
      expect(user).not_to be_organizer

      FactoryBot.create(:organizer, user: user)

      expect(user).to be_organizer
      expect(user.reload).to be_organizer
    end

    it 'removes organizer role after destroyed' do
      organizer = FactoryBot.create(:organizer, user: user)
      expect(user).to be_organizer
      organizer.destroy
      expect(user).not_to be_organizer
      expect(user.reload).not_to be_organizer
    end

    it 'keeps organizer role after destroyed if user organizes other tracks' do
      other_organizer = FactoryBot.create(:organizer, user: user)
      track = FactoryBot.create(:track, conference: other_organizer.conference)
      organizer = FactoryBot.create(:organizer, user: user, track: track, conference: other_organizer.conference)
      expect(user).to be_organizer
      organizer.destroy
      expect(user).to be_organizer
      expect(user.reload).to be_organizer
    end

    it 'removes organizer role after update' do
      organizer = FactoryBot.create(:organizer, user: user)
      another_user = FactoryBot.create(:user)
      organizer.user = another_user
      organizer.save
      expect(user.reload).not_to be_organizer
      expect(another_user).to be_organizer
    end

    it 'keeps organizer role after update if user organizes other tracks' do
      other_organizer = FactoryBot.create(:organizer, user: user)
      track = FactoryBot.create(:track, conference: other_organizer.conference)
      organizer = FactoryBot.create(:organizer, user: user, track: track, conference: other_organizer.conference)
      another_user = FactoryBot.create(:user)
      organizer.user = another_user
      organizer.save
      expect(user.reload).to be_organizer
      expect(another_user).to be_organizer
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe 'managing organizer role for normal user' do
    let(:user) { FactoryBot.create(:user) }

    it_behaves_like 'organizer role'
  end

  describe 'managing organizer role for simple user' do
    let(:user) { FactoryBot.create(:simple_user) }

    it_behaves_like 'organizer role'
  end
end
