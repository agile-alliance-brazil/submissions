# encoding: UTF-8
require 'spec_helper'

describe Conference do
  context "associations" do
    it { should have_many :tracks }
    it { should have_many :audience_levels }
    it { should have_many :session_types }
  end

  it "should overide to_param with year" do
    Conference.find_by_year(2010).to_param.should == "2010"
    Conference.find_by_year(2011).to_param.should == "2011"
    Conference.find_by_year(2012).to_param.should == "2012"
  end

  context "dates" do
    it "should return a hash with dates and symbols" do
      conference = Conference.find_by_year(2010)
      conference.dates.should == [
        [conference.call_for_papers.to_date, :call_for_papers],
        [conference.submissions_open.to_date, :submissions_open],
        [conference.submissions_deadline.to_date, :submissions_deadline],
        [conference.author_notification.to_date, :author_notification],
        [conference.author_confirmation.to_date, :author_confirmation]
      ]
    end
  end
end
