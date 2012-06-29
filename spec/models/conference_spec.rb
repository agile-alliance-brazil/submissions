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
          DateTime.expects(:now).returns(@conference.presubmissions_deadline - 1.second)
          @conference.next_deadline(:author).should == [@conference.presubmissions_deadline, :presubmissions_deadline]
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
          DateTime.expects(:now).returns(@conference.prereview_deadline - 1.second)
          @conference.next_deadline(:reviewer).should == [@conference.prereview_deadline, :prereview_deadline]
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

    {
      :submission_phase   => [:submissions_open, :submissions_deadline],
      :early_review_phase => [:presubmissions_deadline, :prereview_deadline],
      :final_review_phase => [:submissions_deadline, :review_deadline],
      :author_confirmation_phase => [:author_notification, :author_confirmation]
    }.each do |phase, deadlines|
      describe "in_#{phase}?" do
        before(:each) do
          @conference = Conference.find_by_year(2012)
          @start = @conference.send(deadlines[0])
          @end = @conference.send(deadlines[1])
        end

        it "should return true if date is on start deadline" do
          DateTime.expects(:now).returns(@start)
          @conference.send(:"in_#{phase}?").should be_true
        end

        it "should return false if date is before start deadline" do
          DateTime.expects(:now).returns(@start - 1.second)
          @conference.send(:"in_#{phase}?").should be_false
        end

        it "should return true if date is after start deadline" do
          DateTime.expects(:now).returns(@start + 1.second)
          @conference.send(:"in_#{phase}?").should be_true
        end

        it "should return true if date is prior to end deadline" do
          DateTime.expects(:now).returns(@end - 1.second)
          @conference.send(:"in_#{phase}?").should be_true
        end

        it "should return true if date is on end deadline" do
          DateTime.expects(:now).returns(@end)
          @conference.send(:"in_#{phase}?").should be_true
        end

        it "should return false if date is after end deadline" do
          DateTime.expects(:now).returns(@end + 1.second)
          @conference.send(:"in_#{phase}?").should be_false
        end
      end
    end

    it "should not fail if conference doesn't have early review" do
      conference = Conference.find_by_year(2011)
      DateTime.stubs(:now).returns(conference.submissions_open)
      conference.should_not be_in_early_review_phase
    end
  end

end
