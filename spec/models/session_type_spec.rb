# encoding: UTF-8
require 'spec_helper'

describe SessionType, type: :model do
  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
  end

  context "associations" do
    it { should have_many :sessions }
    it { should belong_to :conference }
  end

  context "types" do
    before(:each) do
      @tutorial = FactoryGirl.create(:session_type, title: 'session_types.tutorial.title')
      @lightning_talk = FactoryGirl.create(:session_type, title: 'session_types.lightning_talk.title')

      SessionType.stubs(:select).with(:title).returns(SessionType)
      SessionType.stubs(:uniq).returns([@tutorial, @lightning_talk])
    end
    it "should detect all titles" do
      expect(SessionType.all_titles).to eq(%w[tutorial lightning_talk])
    end

    it "should determine if it's tutorial" do
      session_type = FactoryGirl.build(:session_type, title: "session_types.tutorial.title")
      expect(session_type.send(:tutorial?)).to be true
      session_type = FactoryGirl.build(:session_type, title: 'session_types.other.title')
      expect(session_type.send(:tutorial?)).to be false
    end

    it "should determine if it's lightning talk" do
      session_type = FactoryGirl.build(:session_type, title: "session_types.lightning_talk.title")
      expect(session_type.send(:lightning_talk?)).to be true
      session_type = FactoryGirl.build(:session_type, title: 'session_types.other.title')
      expect(session_type.send(:lightning_talk?)).to be false
    end
  end
end
