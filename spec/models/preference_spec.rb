# encoding: UTF-8
# frozen_string_literal: true

require 'spec_helper'

describe Preference, type: :model do
  context 'validations' do
    describe 'when accepted' do
      let(:old_conference) { FactoryGirl.create(:conference, year: 1) }
      let(:conference) { FactoryGirl.create(:conference) }
      let(:reviewer) { FactoryGirl.create(:reviewer, conference: conference) }
      subject { FactoryGirl.build(:preference, accepted: true, reviewer: reviewer) }
      it { should validate_presence_of :audience_level_id }
      it { should validate_presence_of :track_id }

      should_validate_existence_of :audience_level, :track

      it "should match the preference track to the reviewer's conference" do
        subject.track = FactoryGirl.create(:track, conference: old_conference)
        expect(subject).to_not be_valid
        expect(subject.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
      end

      it "should match the preference audience level to the reviewer's conference" do
        subject.audience_level = FactoryGirl.create(:audience_level, conference: old_conference)
        expect(subject).to_not be_valid
        expect(subject.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
      end

      context 'reviewer from another conference' do
        let(:reviewer_for_other_conference) { FactoryGirl.create(:reviewer, conference: old_conference) }
        before(:each) do
          subject.reviewer = reviewer_for_other_conference
        end

        it "should match the preference track to the reviewer's conference" do
          expect(subject).to_not be_valid
          expect(subject.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
        end

        it "should match the preference audience level to the reviewer's conference" do
          expect(subject).to_not be_valid
          expect(subject.errors[:audience_level_id]).to include(I18n.t('errors.messages.same_conference'))
        end
      end
    end

    should_validate_existence_of :reviewer

    describe 'should validate preference for organizer' do
      let(:organizer) { FactoryGirl.create(:organizer) }

      it 'cannot choose track that is being organized by him/her' do
        preference = FactoryGirl.build(:preference)
        expect(preference).to be_valid
        preference.reviewer.user = organizer.user
        preference.reviewer.conference = organizer.conference
        preference.track = organizer.track
        expect(preference).to_not be_valid
        expect(preference.errors[:accepted]).to include(I18n.t('activerecord.errors.models.preference.organizer_track'))
      end
    end
  end

  context 'associations' do
    it { should belong_to :reviewer }
    it { should belong_to :track }
    it { should belong_to :audience_level }

    it { should have_one(:user).through(:reviewer) }
  end
end
