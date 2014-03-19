# encoding: UTF-8
require 'spec_helper'

describe SessionType do

  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
  end

  context "associations" do
    it { should have_many :sessions }
    it { should belong_to :conference }
  end

  it "should detect all titles" do
    (SessionType.all_titles - %w[tutorial workshop talk lightning_talk hands_on experience_report traditional_talk duel]).should be_empty
  end

  SessionType.all_titles.each do |title|
    it "should determine if it's #{title}" do
      session_type = FactoryGirl.build(:session_type, :title => "session_types.#{title}.title")
      session_type.send(:"#{title}?").should be_true
      session_type = FactoryGirl.build(:session_type, :title => 'session_types.other.title')
      session_type.send(:"#{title}?").should be_false
    end
  end
end
