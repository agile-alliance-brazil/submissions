# encoding: UTF-8
require 'spec_helper'

describe LightningTalkGroup do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :lightning_talk_info }

    it { should_not allow_mass_assignment_of :id }
  end

  describe "#lightning_talks" do
    it "should fetch Lightning Talks from serialized info" do
      lightning_talks = FactoryGirl.create_list(:session, 2)
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_info => [{
        :id => lightning_talks.first.id,
        :type => "Session",
        :order => 1
      },{
        :id => lightning_talks.second.id,
        :type => "Session",
        :order => 2
      }])
      lightning_talk_group.lightning_talks.should == lightning_talks
    end

    it "should return empty if Lightning Talks not found" do
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_info => [{
        :id => 1,
        :type => "Session",
        :order => 1
      }])
      lightning_talk_group.lightning_talks.should be_empty
    end

    it "should only return Lightning Talks that exist" do
      lightning_talk = FactoryGirl.create(:guest_session)
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_info => [{
        :id => lightning_talk.id,
        :type => "GuestSession",
        :order => 1
      }, {
        :id => 2,
        :type => "Session",
        :order => 2
      }, {
        :id => 3,
        :type => "InvalidClass",
        :order => 3
      }])
      lightning_talk_group.lightning_talks.should == [lightning_talk]
    end
  end

  describe "#author_names" do
    it "should return author's full name for sessions" do
      first_author = FactoryGirl.create(:author, :first_name => "Some", :last_name => "One")
      second_author = FactoryGirl.create(:author, :first_name => "Some", :last_name => "Two")
      lightning_talk = FactoryGirl.create(:session, :author => first_author, :second_author => second_author)
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_info => [{
        :id => lightning_talk.id,
        :type => "Session",
        :order => 1
      }])
      lightning_talk_group.author_names.should == "Some One, Some Two"
    end

    it "should return author name for guest session" do
      lightning_talk = FactoryGirl.create(:guest_session, :author => "Some One")
      lightning_talk_group = FactoryGirl.build(:lightning_talk_group, :lightning_talk_info => [{
        :id => lightning_talk.id,
        :type => "GuestSession",
        :order => 1
      }])
      lightning_talk_group.author_names.should == "Some One"
    end
  end
end
