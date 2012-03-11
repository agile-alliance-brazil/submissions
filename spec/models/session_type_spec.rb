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

  context "named scopes" do
    xit {should have_scope(:for_conference, :with => '1').where('conference_id = 1') }
  end

  it "should determine if it's lightning talk" do
    session_type = SessionType.new(:title => 'session_types.lightning_talk.title')
    session_type.should be_lightning_talk
    session_type = SessionType.new(:title => 'session_types.talk.title')
    session_type.should_not be_lightning_talk
  end

  it "should determine if it's workshop" do
    session_type = SessionType.new(:title => 'session_types.workshop.title')
    session_type.should be_workshop
    session_type = SessionType.new(:title => 'session_types.talk.title')
    session_type.should_not be_workshop
  end

  it "should determine if it's hands on" do
    session_type = SessionType.new(:title => 'session_types.hands_on.title')
    session_type.should be_hands_on
    session_type = SessionType.new(:title => 'session_types.talk.title')
    session_type.should_not be_hands_on
  end

  it "should determine if it's talk" do
    session_type = SessionType.new(:title => 'session_types.talk.title')
    session_type.should be_talk
    session_type = SessionType.new(:title => 'session_types.hands_on.title')
    session_type.should_not be_talk
  end
end
