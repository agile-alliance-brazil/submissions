# encoding: UTF-8
require 'spec_helper'

describe Track do
  
  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
  end
  
  context "associations" do
    it { should belong_to :conference }
    it { should have_many :sessions }
    it { should have_many(:track_ownerships).class_name('Organizer') }
    it { should have_many(:organizers).through(:track_ownerships) }
  end
  
  context "named scopes" do
    xit {should have_scope(:for_conference, :with => '1').where('conference_id = 1') }
  end

  it "should determine if it's experience report" do
    track = Track.new(:title => 'tracks.experience_reports.title')
    track.should be_experience_report
    track = Track.new(:title => 'tracks.management.title')
    track.should_not be_experience_report
  end
end
