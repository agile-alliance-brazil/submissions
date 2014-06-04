# encoding: UTF-8
require 'spec_helper'

describe SessionsHelper, type: :helper do

  describe "#all_durations_for" do
    context "empty session types" do
      subject { helper.all_durations_for([]) }
      it { should be_empty }
    end

    context "single session types" do
      subject { helper.all_durations_for([FactoryGirl.build(:session_type, :valid_durations => [10, 20])]) }
      it { should == [10, 20]}
    end

    context "multiple session types" do
      it "should merge durations" do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, :valid_durations => [10, 20]),
          FactoryGirl.build(:session_type, :valid_durations => [30, 40]),
        ])
        durations.should == [10, 20, 30, 40]
      end

      it "should remove duplicates" do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, :valid_durations => [10, 20]),
          FactoryGirl.build(:session_type, :valid_durations => [20, 30]),
        ])
        durations.should == [10, 20, 30]
      end

      it "should sort durations" do
        durations = helper.all_durations_for([
          FactoryGirl.build(:session_type, :valid_durations => [20, 40]),
          FactoryGirl.build(:session_type, :valid_durations => [30, 10]),
        ])
        durations.should == [10, 20, 30, 40]
      end
    end
  end

  describe "#options_for_durations" do
    it "should return human readable collection of durations" do
      options = helper.options_for_durations([
        FactoryGirl.build(:session_type, :valid_durations => [20, 40]),
        FactoryGirl.build(:session_type, :valid_durations => [10, 20]),
      ])
      options.should == [["10 #{t('generic.minutes')}", 10], ["20 #{t('generic.minutes')}", 20], ["40 #{t('generic.minutes')}", 40]]
    end
  end

  describe "#durations_to_hide" do
    it "should return durations to hide as strings" do
      session_type_1 = FactoryGirl.create(:session_type, :valid_durations => [20, 40])
      session_type_2 = FactoryGirl.create(:session_type, :valid_durations => [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type_1, session_type_2])
      durations_to_hide[session_type_1.id].should == ["10"]
      durations_to_hide[session_type_2.id].should == ["40"]
    end

    it "should hide default option when session type only accepts a single duration" do
      session_type_1 = FactoryGirl.create(:session_type, :valid_durations => [40])
      session_type_2 = FactoryGirl.create(:session_type, :valid_durations => [10, 20])
      durations_to_hide = helper.durations_to_hide([session_type_1, session_type_2])
      durations_to_hide[session_type_1.id].should == ["10", "20", ""]
      durations_to_hide[session_type_2.id].should == ["40"]
    end
  end

  describe "#duration_mins_hint" do
    it "should generate hint from session types in portuguese" do
      I18n.with_locale('pt') do
        hint = helper.duration_mins_hint([
          FactoryGirl.build(:session_type, :title => "session_types.talk.title", :valid_durations => [20, 40]),
          FactoryGirl.build(:session_type, :title => "session_types.experience_report.title", :valid_durations => [10]),
          FactoryGirl.build(:session_type, :title => "session_types.hands_on.title", :valid_durations => [30, 20])
        ])
        hint.should == "Palestras devem ter duração de 20 ou 40 minutos, relatos de experiência 10 minutos e sessões mão na massa 20 ou 30 minutos."
      end
    end

    it "should generate hint from session types in english" do
      I18n.with_locale('en') do
        hint = helper.duration_mins_hint([
          FactoryGirl.build(:session_type, :title => "session_types.workshop.title", :valid_durations => [20]),
          FactoryGirl.build(:session_type, :title => "session_types.hands_on.title", :valid_durations => [40])
        ])
        hint.should == "Workshops should last 20 minutes and hands on sessions 40 minutes."
      end
    end
  end
end
