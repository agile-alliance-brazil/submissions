# encoding: UTF-8
require 'spec_helper'

describe Conference, type: :model do
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

  describe "deadlines" do
    describe "dates" do
      it "should return a hash with dates and symbols" do
        conference = Conference.find_by_year(2010)
        conference.dates.should == [
          [conference.call_for_papers, :call_for_papers],
          [conference.submissions_open, :submissions_open],
          [conference.submissions_deadline, :submissions_deadline],
          [conference.author_notification, :author_notification],
          [conference.author_confirmation, :author_confirmation]
        ]
      end

      it "should include pre-submission and pre-review deadlines when available" do
        conference = Conference.find_by_year(2012)
        conference.dates.should == [
          [conference.submissions_open, :submissions_open],
          [conference.presubmissions_deadline, :presubmissions_deadline],
          [conference.prereview_deadline, :prereview_deadline],
          [conference.submissions_deadline, :submissions_deadline],
          [conference.author_notification, :author_notification],
          [conference.author_confirmation, :author_confirmation]
        ]
      end
    end

    describe "next_deadline" do
      before(:each) do
        @conference = Conference.current
      end

      context "for authors" do
        it "should show pre submissions deadline first" do
          conference = Conference.where(:year => 2012).first
          DateTime.expects(:now).returns(conference.presubmissions_deadline - 1.second)
          conference.next_deadline(:author).should == [conference.presubmissions_deadline, :presubmissions_deadline]
        end

        it "should show submissions deadline first if conference doesn't have pre submissions" do
          conference = Conference.first
          DateTime.expects(:now).returns(conference.submissions_deadline - 1.second)
          conference.next_deadline(:author).should == [conference.submissions_deadline, :submissions_deadline]
        end

        it "should show submissions deadline second" do
          DateTime.expects(:now).returns(@conference.submissions_deadline - 1.second)
          @conference.next_deadline(:author).should == [@conference.submissions_deadline, :submissions_deadline]
        end

        it "should show author notification deadline third" do
          DateTime.expects(:now).returns(@conference.author_notification - 1.second)
          @conference.next_deadline(:author).should == [@conference.author_notification, :author_notification]
        end

        it "should show author confirmation deadline last" do
          DateTime.expects(:now).returns(@conference.author_confirmation - 1.second)
          @conference.next_deadline(:author).should == [@conference.author_confirmation, :author_confirmation]
        end

        it "should be nil after author confirmation" do
          DateTime.expects(:now).returns(@conference.author_confirmation + 1.second)
          @conference.next_deadline(:author).should be_nil
        end
      end

      context "for reviewers" do
        it "should show pre review deadline first" do
          conference = Conference.where(:year => 2012).first
          DateTime.expects(:now).returns(conference.prereview_deadline - 1.second)
          conference.next_deadline(:reviewer).should == [conference.prereview_deadline, :prereview_deadline]
        end

        it "should show review deadline first if conference doesn't have pre submissions" do
          conference = Conference.first
          DateTime.expects(:now).returns(conference.review_deadline - 1.second)
          conference.next_deadline(:reviewer).should == [conference.review_deadline, :review_deadline]
        end

        it "should be nil after review deadline" do
          DateTime.expects(:now).returns(@conference.review_deadline + 1.second)
          @conference.next_deadline(:reviewer).should be_nil
        end
      end
    end

    describe "in_submission_phase?" do
      before(:each) do
        @conference = Conference.find_by_year(2012)
        @start = @conference.submissions_open
        @end = @conference.submissions_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        @conference.should be_in_submission_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        @conference.should_not be_in_submission_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        @conference.should be_in_submission_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        @conference.should be_in_submission_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        @conference.should be_in_submission_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        @conference.should_not be_in_submission_phase
      end
    end

    describe "in_early_review_phase?" do
      before(:each) do
        @conference = Conference.find_by_year(2012)
        @start = @conference.presubmissions_deadline
        @end = @conference.prereview_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        @conference.should be_in_early_review_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        @conference.should_not be_in_early_review_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        @conference.should be_in_early_review_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        @conference.should be_in_early_review_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        @conference.should be_in_early_review_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        @conference.should_not be_in_early_review_phase
      end
    end

    describe "in_final_review_phase?" do
      before(:each) do
        @conference = Conference.find_by_year(2012)
        @start = @conference.submissions_deadline
        @end = @conference.review_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        @conference.should be_in_final_review_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        @conference.should_not be_in_final_review_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        @conference.should be_in_final_review_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        @conference.should be_in_final_review_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        @conference.should be_in_final_review_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        @conference.should_not be_in_final_review_phase
      end
    end

    describe "in_author_confirmation_phase?" do
      before(:each) do
        @conference = Conference.find_by_year(2012)
        @start = @conference.author_notification
        @end = @conference.author_confirmation
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        @conference.should be_in_author_confirmation_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        @conference.should_not be_in_author_confirmation_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        @conference.should be_in_author_confirmation_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        @conference.should be_in_author_confirmation_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        @conference.should be_in_author_confirmation_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        @conference.should_not be_in_author_confirmation_phase
      end
    end

    it "should not fail if conference doesn't have early review" do
      conference = Conference.find_by_year(2011)
      DateTime.stubs(:now).returns(conference.submissions_open)
      conference.should_not be_in_early_review_phase
    end

    describe "in_voting_deadline?" do
      before do
        @conference = Conference.find_by_year(2013)
      end

      it "should be true if date is prior to voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline - 1.second)
        @conference.should be_in_voting_phase
      end

      it "should be true if date is on voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline)
        @conference.should be_in_voting_phase
      end

      it "should be false if date is after voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline + 1.second)
        @conference.should_not be_in_voting_phase
      end

      it "should be false if conference doesn't have a voting deadline" do
        conference = Conference.find_by_year(2011)
        conference.should_not be_in_voting_phase
      end
    end
  end

end
