# encoding: UTF-8
require 'spec_helper'

describe LightningTalkGroup do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :lightning_talk_ids }

    it { should_not allow_mass_assignment_of :id }
  end

  describe "#lightning_talks" do
    it "should fetch Lightning Talks from IDs" do
      lightning_talks = FactoryGirl.create_list(:session, 2)
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_ids => lightning_talks.map(&:id))
      lightning_talk_group.lightning_talks.should == lightning_talks
    end

    it "should return empty if Lightning Talks not found" do
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_ids => [1, 2])
      lightning_talk_group.lightning_talks.should be_empty
    end

    it "should only return Lightning Talks that exist" do
      lightning_talk = FactoryGirl.create(:session)
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_ids => [lightning_talk.id, 2])
      lightning_talk_group.lightning_talks.should == [lightning_talk]
    end
  end
end
