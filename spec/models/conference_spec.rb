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

  describe "dates" do
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
    
    it "should include pre-submission and pre-review deadlines when available" do
      conference = Conference.find_by_year(2012)
      conference.dates.should == [
        [conference.submissions_open.to_date, :submissions_open],
        [conference.presubmissions_deadline.to_date, :presubmissions_deadline],
        [conference.prereview_deadline.to_date, :prereview_deadline],
        [conference.submissions_deadline.to_date, :submissions_deadline],
        [conference.author_notification.to_date, :author_notification],
        [conference.author_confirmation.to_date, :author_confirmation]
      ]
    end
  end
  
  describe "current_date" do
    before :each do
      @date = DateTime.now
      @conference = Conference.new
      @dates = [[@date, :submissions], [@date + 1.day, :notification]]
      @conference.expects(:dates).returns(@dates)
    end

    it "should find the first date if conference's first date is previous to now" do
      DateTime.expects(:now).returns(@date - 1.day)
      @conference.current_date.should == @dates.first
    end

    it "should find the second date if conference's second date is previous to now" do
      DateTime.expects(:now).returns(@date + 1.minute)
      @conference.current_date.should == @dates.last
    end

    it "should find nil if current conference's last date is before now" do
      DateTime.expects(:now).returns(@date + 2.days)
      @conference.current_date.should be_nil
    end
  end
end
