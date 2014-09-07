# encoding: UTF-8
require 'spec_helper'

describe Conference, type: :model do
  context "associations" do
    it { should have_many :tracks }
    it { should have_many :audience_levels }
    it { should have_many :session_types }
  end

  it "should overide to_param with year" do
    expect(FactoryGirl.build(:conference, year: 2010).to_param).to eq("2010")
    expect(FactoryGirl.build(:conference, year: 2011).to_param).to eq("2011")
    expect(FactoryGirl.build(:conference, year: 2012).to_param).to eq("2012")
  end

  describe "deadlines" do
    describe "dates" do
      subject { FactoryGirl.build(:conference) }
      it "should return a hash with dates and symbols" do
        subject.presubmissions_deadline = nil
        subject.prereview_deadline = nil
        expect(subject.dates).to eq([
          [subject.call_for_papers, :call_for_papers],
          [subject.submissions_open, :submissions_open],
          [subject.submissions_deadline, :submissions_deadline],
          [subject.author_notification, :author_notification],
          [subject.author_confirmation, :author_confirmation]
        ])
      end

      it "should include pre-submission and pre-review deadlines when available" do
        expect(subject.dates).to eq([
          [subject.call_for_papers, :call_for_papers],
          [subject.submissions_open, :submissions_open],
          [subject.presubmissions_deadline, :presubmissions_deadline],
          [subject.prereview_deadline, :prereview_deadline],
          [subject.submissions_deadline, :submissions_deadline],
          [subject.author_notification, :author_notification],
          [subject.author_confirmation, :author_confirmation]
        ])
      end
    end

    describe "next_deadline" do
      before :each do
        @conference = FactoryGirl.build(:conference)
      end

      context "for authors" do
        it "should show pre submissions deadline first" do
          @conference.presubmissions_deadline = DateTime.now + 3.days
          DateTime.expects(:now).returns(@conference.presubmissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.presubmissions_deadline, :presubmissions_deadline])
        end

        it "should show submissions deadline first if conference doesn't have pre submissions" do
          DateTime.expects(:now).returns(@conference.submissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.submissions_deadline, :submissions_deadline])
        end

        it "should show submissions deadline second" do
          DateTime.expects(:now).returns(@conference.submissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.submissions_deadline, :submissions_deadline])
        end

        it "should show author notification deadline third" do
          DateTime.expects(:now).returns(@conference.author_notification - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.author_notification, :author_notification])
        end

        it "should show author confirmation deadline last" do
          DateTime.expects(:now).returns(@conference.author_confirmation - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.author_confirmation, :author_confirmation])
        end

        it "should be nil after author confirmation" do
          DateTime.expects(:now).returns(@conference.author_confirmation + 1.second)
          expect(@conference.next_deadline(:author)).to be_nil
        end
      end

      context "for reviewers" do
        before :each do
          @conference = FactoryGirl.build(:conference)
        end

        it "should show pre review deadline first" do
          DateTime.expects(:now).returns(@conference.prereview_deadline - 1.second)
          expect(@conference.next_deadline(:reviewer)).to eq([@conference.prereview_deadline, :prereview_deadline])
        end

        it "should show review deadline first if conference doesn't have pre submissions" do
          @conference.prereview_deadline = nil
          DateTime.expects(:now).returns(@conference.review_deadline - 1.second)
          expect(@conference.next_deadline(:reviewer)).to eq([@conference.review_deadline, :review_deadline])
        end

        it "should be nil after review deadline" do
          DateTime.expects(:now).returns(@conference.review_deadline + 1.second)
          expect(@conference.next_deadline(:reviewer)).to be_nil
        end
      end
    end

    describe "in_submission_phase?" do
      before(:each) do
        @conference = FactoryGirl.build(:conference,
          submissions_open: Time.now + 6.days,
          submissions_deadline: Time.now + 10.days)
        @start = @conference.submissions_open
        @end = @conference.submissions_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        expect(@conference).to be_in_submission_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        expect(@conference).to_not be_in_submission_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        expect(@conference).to be_in_submission_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        expect(@conference).to be_in_submission_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        expect(@conference).to be_in_submission_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        expect(@conference).to_not be_in_submission_phase
      end
    end

    describe "in_early_review_phase?" do
      before(:each) do
        @conference = FactoryGirl.build(:conference)
        @start = @conference.presubmissions_deadline
        @end = @conference.prereview_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        expect(@conference).to be_in_early_review_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        expect(@conference).to_not be_in_early_review_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        expect(@conference).to be_in_early_review_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        expect(@conference).to be_in_early_review_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        expect(@conference).to be_in_early_review_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        expect(@conference).to_not be_in_early_review_phase
      end
    end

    describe "in_final_review_phase?" do
      before(:each) do
        @conference = FactoryGirl.build(:conference)
        @start = @conference.submissions_deadline
        @end = @conference.review_deadline
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        expect(@conference).to be_in_final_review_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        expect(@conference).to_not be_in_final_review_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        expect(@conference).to be_in_final_review_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        expect(@conference).to be_in_final_review_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        expect(@conference).to be_in_final_review_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        expect(@conference).to_not be_in_final_review_phase
      end
    end

    describe "in_author_confirmation_phase?" do
      before(:each) do
        @conference = FactoryGirl.build(:conference,
          author_notification: Time.now + 6.days,
          author_confirmation: Time.now + 10.days)
        @start = @conference.author_notification
        @end = @conference.author_confirmation
      end

      it "should return true if date is on start deadline" do
        DateTime.expects(:now).returns(@start)
        expect(@conference).to be_in_author_confirmation_phase
      end

      it "should return false if date is before start deadline" do
        DateTime.expects(:now).returns(@start - 1.second)
        expect(@conference).to_not be_in_author_confirmation_phase
      end

      it "should return true if date is after start deadline" do
        DateTime.expects(:now).returns(@start + 1.second)
        expect(@conference).to be_in_author_confirmation_phase
      end

      it "should return true if date is prior to end deadline" do
        DateTime.expects(:now).returns(@end - 1.second)
        expect(@conference).to be_in_author_confirmation_phase
      end

      it "should return true if date is on end deadline" do
        DateTime.expects(:now).returns(@end)
        expect(@conference).to be_in_author_confirmation_phase
      end

      it "should return false if date is after end deadline" do
        DateTime.expects(:now).returns(@end + 1.second)
        expect(@conference).to_not be_in_author_confirmation_phase
      end
    end

    it "should not fail if conference doesn't have early review" do
      conference = FactoryGirl.build(:conference)
      DateTime.stubs(:now).returns(conference.submissions_open)
      expect(conference).to_not be_in_early_review_phase
    end

    describe "in_voting_deadline?" do
      before do
        @conference = FactoryGirl.build(:conference)
        @conference.voting_deadline = @conference.submissions_deadline + 5.days
      end

      it "should be true if date is prior to voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline - 1.second)
        expect(@conference).to be_in_voting_phase
      end

      it "should be true if date is on voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline)
        expect(@conference).to be_in_voting_phase
      end

      it "should be false if date is after voting deadline" do
        DateTime.stubs(:now).returns(@conference.voting_deadline + 1.second)
        expect(@conference).to_not be_in_voting_phase
      end

      it "should be false if conference doesn't have a voting deadline" do
        conference = FactoryGirl.build(:conference)
        conference.voting_deadline = nil
        expect(conference).to_not be_in_voting_phase
      end
    end
  end

end
