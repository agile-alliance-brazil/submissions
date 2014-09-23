# encoding: UTF-8
require 'spec_helper'

describe Slot, type: :model do
  def at(time)
    Time.parse(time)
  end

  describe "from 09:30 to 10:00" do
    subject { Slot.new(at("09:30"), at("10:00")) }

    its(:start) { should == at("09:30") }
    its(:deadline) { should == at("10:00")}
    its(:duration) { should == 30.minutes }

    it { should_not include(at("09:00")) }
    it { should_not include(at("09:29:59")) }
    it { should     include(at("09:30:00")) }
    it { should     include(at("09:45")) }
    it { should_not include(at("10:00:00")) }
    it { should_not include(at("10:00:01")) }

    it { should     == Slot.new(at("09:30"), at("10:00")) }
  end

  describe "from 15:00 to 16:45" do
    subject { Slot.new(at("15:00"), at("16:45")) }

    its(:start) { should == at("15:00") }
    its(:deadline) { should == at("16:45")}
    its(:duration) { should == 1.hour + 45.minutes }

    it { should_not include(at("09:00")) }
    it { should     include(at("16:00")) }
    it { should_not include(at("17:00")) }
  end

  describe ".from" do
    it "should instantiate Slot with given start and duration" do
      expect(Slot.from(at("08:30"), 30.minutes)).to eq(Slot.new(at("08:30"), at("09:00")))
      expect(Slot.from(at("12:00"), 1.hour)).to eq(Slot.new(at("12:00"), at("13:00")))
    end
  end

  describe ".divide" do
    describe "splits time range in slots of given duration" do
      context "when start == finish" do
        subject { Slot.divide(at("08:00"), at("08:00"), 1.second) }
        it { should be_empty }
      end

      context "when start > finish" do
        subject { Slot.divide(at("08:30"), at("08:00"), 1.second) }
        it { should be_empty }
      end

      context "single slot" do
        subject { Slot.divide(at("08:00"), at("08:30"), 30.minutes) }
        it { should == [Slot.from(at("08:00"), 30.minutes)] }
      end

      context "two slots" do
        subject { Slot.divide(at("08:00"), at("09:00"), 30.minutes) }
        it { should == [Slot.from(at("08:00"), 30.minutes), Slot.from(at("08:30"), 30.minutes)] }
      end

      context "multiple slots" do
        subject { Slot.divide(at("08:00"), at("11:00"), 1.hour) }
        it { should == [Slot.from(at("08:00"), 1.hour), Slot.from(at("09:00"), 1.hour), Slot.from(at("10:00"), 1.hour)] }
      end

      context "remainder interval past finish" do
        subject { Slot.divide(at("08:00"), at("08:30"), 20.minutes) }
        it { should == [Slot.from(at("08:00"), 20.minutes), Slot.from(at("08:20"), 10.minutes)] }
      end

      context "interval > start->finish" do
        subject { Slot.divide(at("08:00"), at("08:30"), 1.hour) }
        it { should == [Slot.from(at("08:00"), 30.minutes)] }
      end
    end
  end
end
