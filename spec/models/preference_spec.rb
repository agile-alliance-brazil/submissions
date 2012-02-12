# encoding: UTF-8
# encoding: utf-8
require 'spec_helper'

describe Preference do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :reviewer_id
    should_allow_mass_assignment_of :track_id
    should_allow_mass_assignment_of :audience_level_id
    should_allow_mass_assignment_of :accepted
  
    should_not_allow_mass_assignment_of :id
  end
  
  context "validations" do
    should_validate_inclusion_of :accepted, :in => [true, false]

    describe "should validate audience level if accepted" do
      subject {FactoryGirl.build(:preference, :accepted => true)}
      should_validate_presence_of :audience_level_id
      should_validate_existence_of :audience_level
    end

    should_validate_existence_of :reviewer, :track

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
    should_belong_to :reviewer
    should_belong_to :track
    should_belong_to :audience_level

    should_have_one :user, :through => :reviewer
  end
end
