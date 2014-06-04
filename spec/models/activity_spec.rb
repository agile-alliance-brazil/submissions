# encoding: UTF-8
require 'spec_helper'

describe Activity, type: :model do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :start_at }
    it { should allow_mass_assignment_of :end_at }
    it { should allow_mass_assignment_of :room_id }
    it { should allow_mass_assignment_of :detail_type }
    it { should allow_mass_assignment_of :detail_id }

    it { should_not allow_mass_assignment_of :id }
  end

  context "associations" do
    it { should belong_to :room }
    it { should belong_to :detail }
  end

  describe "#starts_in?" do
    let(:activity) { FactoryGirl.build(:activity, :start_at => Time.parse("08:00"))}
    subject { activity.starts_in?(slot) }

    context "starting along with slot" do
      let(:slot) { Slot.from(Time.parse("08:00"), 30.minutes) }
      it { should be true }
    end

    context "starting prior to slot" do
      let(:slot) { Slot.from(Time.parse("08:30"), 30.minutes) }
      it { should be false }
    end

    context "starting after slot" do
      let(:slot) { Slot.from(Time.parse("07:30"), 30.minutes) }
      it { should be false }
    end
  end

  describe "#in_room?" do
    let(:activity) { FactoryGirl.build(:activity)}
    subject { activity.in_room?(room) }

    context "on same room" do
      let(:room) { activity.room }
      it { should be true }
    end

    context "on a different room" do
      let(:room) { FactoryGirl.build(:room) }
      it { should be false }
    end
  end

  describe "#slots_remaining" do
    let(:activity) { FactoryGirl.build(:activity, :start_at => Time.parse("08:00"), :end_at => Time.parse("09:00")) }
    subject { activity.slots_remaining(slot) }

    context "single slot" do
      let(:slot) { Slot.from(Time.parse("08:00"), 1.hour) }
      it { should == 1 }
    end

    context "multiple slots" do
      let(:slot) { Slot.from(Time.parse("08:00"), 30.minutes) }
      it { should == 2 }
    end

    context "irregular-sized slots" do
      let(:slot) { Slot.from(Time.parse("08:00"), 40.minutes) }
      it { should == 2 }
    end

    context "larger slot" do
      let(:slot) { Slot.from(Time.parse("08:00"), 2.hours) }
      it { should == 1 }
    end
  end

  describe "normal session" do
    subject { FactoryGirl.build(:activity, :detail => FactoryGirl.build(:session)) }

    it { should_not be_all_rooms }
    it { should_not be_keynote }
    it { should_not be_all_hands }
    it { should_not be_wbma }
    it { should_not be_executive_summit }
    its(:css_classes) { should == ["activity", "session"] }
  end

  describe "normal guest session" do
    subject { FactoryGirl.build(:activity, :detail => FactoryGirl.build(:guest_session, :keynote => false)) }

    it { should_not be_all_rooms }
    it { should_not be_keynote }
    it { should_not be_all_hands }
    it { should_not be_wbma }
    it { should_not be_executive_summit }
    its(:css_classes) { should == ["activity", "guest_session"] }
  end

  describe "keynote guest session" do
    subject { FactoryGirl.build(:activity, :detail => FactoryGirl.build(:guest_session, :keynote => true)) }

    it { should be_all_rooms }
    it { should be_keynote }
    it { should_not be_all_hands }
    it { should_not be_wbma }
    it { should_not be_executive_summit }
    its(:css_classes) { should == ["activity", "keynote"] }
  end

  describe "all hands session" do
    subject { FactoryGirl.build(:activity, :detail => FactoryGirl.build(:all_hands)) }

    it { should be_all_rooms }
    it { should_not be_keynote }
    it { should be_all_hands }
    it { should_not be_wbma }
    it { should_not be_executive_summit }
    its(:css_classes) { should == ["activity", "all_hands"] }
  end

  describe "wbma session" do
    subject { FactoryGirl.build(:activity, :room => Room.find(6), :detail => FactoryGirl.build(:guest_session)) }

    it { should be_all_rooms }
    it { should be_keynote }
    it { should_not be_all_hands }
    it { should be_wbma }
    it { should_not be_executive_summit }
    its(:css_classes) { should == ["activity", "keynote"] }
  end

  describe "executive summit session" do
    subject { FactoryGirl.build(:activity, :room => Room.find(7), :detail => FactoryGirl.build(:guest_session)) }

    it { should be_all_rooms }
    it { should be_keynote }
    it { should_not be_all_hands }
    it { should_not be_wbma }
    it { should be_executive_summit }
    its(:css_classes) { should == ["activity", "keynote"] }
  end
end