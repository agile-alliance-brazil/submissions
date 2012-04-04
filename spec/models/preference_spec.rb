# encoding: UTF-8
require 'spec_helper'

describe Preference do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :reviewer_id }
    it { should allow_mass_assignment_of :track_id }
    it { should allow_mass_assignment_of :audience_level_id }
    it { should allow_mass_assignment_of :accepted }

    it { should_not allow_mass_assignment_of :id }
  end
  
  context "validations" do
    xit { should ensure_inclusion_of(:accepted).in_range([true, false]) }

    describe "should validate audience level if accepted" do
      subject {FactoryGirl.build(:preference, :accepted => true)}
      it { should validate_presence_of :audience_level_id }
    end

    should_validate_existence_of :reviewer, :track
    should_validate_existence_of :audience_level, :allow_blank => true

    context "track" do
      it "should match the conference" do
        reviewer = FactoryGirl.create(:reviewer, :conference => Conference.first)
        preference = FactoryGirl.build(:preference, :reviewer => reviewer, :accepted => true)
        preference.should_not be_valid
        preference.errors[:track_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "audience level" do
      it "should match the conference" do
        reviewer = FactoryGirl.create(:reviewer, :conference => Conference.first)
        preference = FactoryGirl.build(:preference, :reviewer => reviewer, :accepted => true)
        preference.should_not be_valid
        preference.errors[:audience_level_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    describe "should validate preference for organizer" do
      before(:each) do
        @organizer = FactoryGirl.create(:organizer)
      end
      
      it "cannot choose track that is being organized by him/her" do
        preference = FactoryGirl.build(:preference)
        preference.should be_valid
        preference.reviewer.user = @organizer.user
        preference.reviewer.conference = @organizer.conference
        preference.track = @organizer.track
        preference.should_not be_valid
        preference.errors[:accepted].should include("não pode avaliar trilha que está organizando")
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
