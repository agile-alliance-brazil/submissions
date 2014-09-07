# encoding: UTF-8
require 'spec_helper'

describe Preference, type: :model do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :reviewer_id }
    it { should allow_mass_assignment_of :track_id }
    it { should allow_mass_assignment_of :audience_level_id }
    it { should allow_mass_assignment_of :track }
    it { should allow_mass_assignment_of :audience_level }
    it { should allow_mass_assignment_of :accepted }

    it { should_not allow_mass_assignment_of :id }
  end

  context "validations" do
    describe "when accepted" do
      subject {FactoryGirl.build(:preference, accepted: true)}
      it { should validate_presence_of :audience_level_id }

      should_validate_existence_of :audience_level, :track, allow_blank: true
      before :each do
        @old_conference = FactoryGirl.create(:conference)
      end

      it "track should match the conference" do
        subject.reviewer = FactoryGirl.create(:reviewer, conference: @old_conference)
        expect(subject).to_not be_valid
        expect(subject.errors[:track_id]).to include(I18n.t("errors.messages.same_conference"))
      end

      it "audience level should match the conference" do
        subject.reviewer = FactoryGirl.create(:reviewer, conference: @old_conference)
        expect(subject).to_not be_valid
        expect(subject.errors[:audience_level_id]).to include(I18n.t("errors.messages.same_conference"))
      end
    end

    should_validate_existence_of :reviewer

    describe "should validate preference for organizer" do
      before(:each) do
        @organizer = FactoryGirl.create(:organizer)
      end

      it "cannot choose track that is being organized by him/her" do
        preference = FactoryGirl.build(:preference)
        expect(preference).to be_valid
        preference.reviewer.user = @organizer.user
        preference.reviewer.conference = @organizer.conference
        preference.track = @organizer.track
        expect(preference).to_not be_valid
        expect(preference.errors[:accepted]).to include(I18n.t("activerecord.errors.models.preference.organizer_track"))
      end
    end
  end

  context "associations" do
    it { should belong_to :reviewer }
    it { should belong_to :track }
    it { should belong_to :audience_level }

    it { should have_one(:user).through(:reviewer) }
  end
end
