# frozen_string_literal: true

require 'spec_helper'

describe Preference, type: :model do
  describe 'validations' do
    describe 'when accepted' do
      subject(:preference) { FactoryBot.build(:preference, accepted: true, reviewer: reviewer) }

      let(:old_conference) { FactoryBot.create(:conference, year: 1) }
      let(:conference) { FactoryBot.create(:conference) }
      let(:reviewer) { FactoryBot.create(:reviewer, conference: conference) }

      it { is_expected.to validate_presence_of :audience_level_id }
      it { is_expected.to validate_presence_of :track_id }

      should_validate_existence_of :audience_level, :track

      it "matches the preference track to the reviewer's conference" do
        preference.track = FactoryBot.create(:track, conference: old_conference)
        expect(preference).not_to be_valid
        expect(preference.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
      end

      it "matches the preference audience level to the reviewer's conference" do
        preference.audience_level = FactoryBot.create(:audience_level, conference: old_conference)
        expect(preference).not_to be_valid
        expect(preference.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
      end

      describe 'reviewer from another conference' do
        let(:reviewer_for_other_conference) { FactoryBot.create(:reviewer, conference: old_conference) }

        before do
          preference.reviewer = reviewer_for_other_conference
        end

        it "matches the preference track to the reviewer's conference" do
          expect(preference).not_to be_valid
          expect(preference.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
        end

        it "matches the preference audience level to the reviewer's conference" do
          expect(preference).not_to be_valid
          expect(preference.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end
    end

    should_validate_existence_of :reviewer

    describe 'should validate preference for organizer' do
      subject(:preference) { FactoryBot.build(:preference, track: organizer.track) }

      let(:organizer) { FactoryBot.build(:organizer) }

      it 'is valid for non organizer' do
        expect(preference).to be_valid
      end

      it 'is invalid for organizer of said track' do
        organizer.save!
        preference.reviewer.user = organizer.user
        preference.reviewer.conference = organizer.conference
        expect(preference).not_to be_valid
        expect(preference.errors[:accepted]).to include(I18n.t('activerecord.errors.models.preference.organizer_track'))
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :reviewer }
    it { is_expected.to belong_to :track }
    it { is_expected.to belong_to :audience_level }

    it { is_expected.to have_one(:user).through(:reviewer) }
  end
end
