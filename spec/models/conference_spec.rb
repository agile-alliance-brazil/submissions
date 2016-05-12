# encoding: UTF-8
require 'spec_helper'

describe Conference, type: :model do
  context 'associations' do
    it { should have_many :tracks }
    it { should have_many :audience_levels }
    it { should have_many :session_types }
    it { should have_many :pages }
  end

  context 'validations' do
    it { should validate_presence_of :year }
    it { should validate_presence_of :name }

    context 'if visible' do
      subject { FactoryGirl.build(:conference, visible: true) }
      it { should validate_presence_of :location }
      it { should validate_presence_of :start_date }
      it { should validate_presence_of :end_date }
      it { should validate_presence_of :submissions_open }
      it { should validate_presence_of :submissions_deadline }
      it { should validate_presence_of :review_deadline }
      it { should validate_presence_of :author_notification }
      it { should validate_presence_of :author_confirmation }
      it { should have_attached_file(:logo) }
      it { should validate_attachment_presence(:logo) }
      it { should validate_attachment_content_type(:logo).
                    allowing('image/png', 'image/gif').
                    rejecting('text/plain', 'text/xml') }
      it { should validate_attachment_size(:logo).
                    less_than(1.megabytes) }
    end

    context 'if not visible' do
      subject { FactoryGirl.build(:conference, visible: false) }
      it { should_not validate_presence_of :location }
      it { should_not validate_presence_of :start_date }
      it { should_not validate_presence_of :end_date }
      it { should_not validate_presence_of :submissions_open }
      it { should_not validate_presence_of :submissions_deadline }
      it { should_not validate_presence_of :review_deadline }
      it { should_not validate_presence_of :author_notification }
      it { should_not validate_presence_of :author_confirmation }
      it { should_not validate_attachment_presence(:logo) }
      it { should_not validate_attachment_content_type(:logo).
                    allowing('image/png', 'image/gif').
                    rejecting('text/plain', 'text/xml') }
      it { should_not validate_attachment_size(:logo).
                    less_than(1.megabytes) }
    end

    context 'date orders' do
      subject { FactoryGirl.build(:conference) }
      Conference::DATE_ORDERS.each_cons(2) do |date1, date2|
        it "should validate that #{date1} comes before #{date2} if both are set" do
          d2 = subject.send(date2)
          subject.send("#{date1}=".to_sym, d2 + 1.day)

          expect(subject).to_not be_valid
          error_message = I18n.t('errors.messages.cant_be_after', date: I18n.t("conference.dates.#{date2}"))
          expect(subject.errors[date1]).to include(error_message)
        end
      end
      it 'should be valid if a single date is entered' do
        Conference::DATE_ORDERS[0..-1].each {|d| subject.send("#{d}=", nil)}
        subject.visible = false

        expect(subject).to be_valid
      end
    end

    it "should validate that year doesn't change" do
      subject = FactoryGirl.create(:conference)
      subject.year += 9999

      expect(subject).to_not be_valid
      expect(subject.errors[:year]).to include(I18n.t('errors.messages.constant'))
    end
  end

  context 'location_and_date' do
    context 'for start and end in the same month' do
      subject do
        FactoryGirl.build(:conference,
          start_date: Time.zone.local(2010, 6, 22),
          end_date: Time.zone.local(2010, 6, 25))
      end

      it 'should compile location_and_date to location followed by start day and end day with month and year' do
        expect(subject.location_and_date).to eq("#{subject.location}, 22-25 Jun, 2010")
      end
    end

    context 'for start and end in different months' do
      subject do
        FactoryGirl.build(:conference,
          start_date: Time.zone.local(2011, 6, 27),
          end_date: Time.zone.local(2011, 7, 1))
      end

      it 'should compile location_and_date to location followed by start day and month and end day with month and year' do
        expect(subject.location_and_date).to eq("#{subject.location}, 27/Jun - 1/Jul, 2011")
      end
    end

    context 'for start and end in different years' do
      subject do
        FactoryGirl.build(:conference,
          start_date: Time.zone.local(2011, 11, 30),
          end_date: Time.zone.local(2012, 1, 2))
      end

      it 'should compile location_and_date to location followed by start date and end date' do
        expect(subject.location_and_date).to eq("#{subject.location}, 30/Nov, 2011 - 2/Jan, 2012")
      end
    end

    context 'without start and end' do
      subject do
        FactoryGirl.build(:conference, start_date: nil, end_date: nil)
      end

      it 'should compile location_and_date to location followed by start date and end date' do
        expect(subject.location_and_date).to eq("#{subject.location}")
      end
    end
  end

  it 'should overide to_param with year' do
    expect(FactoryGirl.build(:conference, year: 2010).to_param).to eq('2010')
    expect(FactoryGirl.build(:conference, year: 2011).to_param).to eq('2011')
    expect(FactoryGirl.build(:conference, year: 2012).to_param).to eq('2012')
  end

  describe 'deadlines' do
    describe 'dates' do
      subject { FactoryGirl.build(:conference) }
      it 'should return a hash with dates and symbols' do
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

      it 'should include pre-submission and pre-review deadlines when available' do
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

    describe 'next_deadline' do
      before :each do
        @conference = FactoryGirl.build(:conference)
      end

      context 'for authors' do
        it 'should show pre submissions deadline first' do
          @conference.presubmissions_deadline = DateTime.now + 3.days
          DateTime.expects(:now).returns(@conference.presubmissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.presubmissions_deadline, :presubmissions_deadline])
        end

        it "should show submissions deadline first if conference doesn't have pre submissions" do
          DateTime.expects(:now).returns(@conference.submissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.submissions_deadline, :submissions_deadline])
        end

        it 'should show submissions deadline second' do
          DateTime.expects(:now).returns(@conference.submissions_deadline - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.submissions_deadline, :submissions_deadline])
        end

        it 'should show author notification deadline third' do
          DateTime.expects(:now).returns(@conference.author_notification - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.author_notification, :author_notification])
        end

        it 'should show author confirmation deadline last' do
          DateTime.expects(:now).returns(@conference.author_confirmation - 1.second)
          expect(@conference.next_deadline(:author)).to eq([@conference.author_confirmation, :author_confirmation])
        end

        it 'should be nil after author confirmation' do
          DateTime.expects(:now).returns(@conference.author_confirmation + 1.second)
          expect(@conference.next_deadline(:author)).to be_nil
        end
      end

      context 'for reviewers' do
        before :each do
          @conference = FactoryGirl.build(:conference)
        end

        it 'should show pre review deadline first' do
          DateTime.expects(:now).returns(@conference.prereview_deadline - 1.second)
          expect(@conference.next_deadline(:reviewer)).to eq([@conference.prereview_deadline, :prereview_deadline])
        end

        it "should show review deadline first if conference doesn't have pre submissions" do
          @conference.prereview_deadline = nil
          DateTime.expects(:now).returns(@conference.review_deadline - 1.second)
          expect(@conference.next_deadline(:reviewer)).to eq([@conference.review_deadline, :review_deadline])
        end

        it 'should be nil after review deadline' do
          DateTime.expects(:now).returns(@conference.review_deadline + 1.second)
          expect(@conference.next_deadline(:reviewer)).to be_nil
        end
      end
    end

    describe 'in_submission_phase?' do
      before(:each) do
        @conference = FactoryGirl.build(:conference,
          submissions_open: Time.now + 6.days,
          submissions_deadline: Time.now + 10.days)
        @start = @conference.submissions_open
        @end = @conference.submissions_deadline
      end

      it 'should return true if date is on start deadline' do
        DateTime.expects(:now).returns(@start)

        expect(@conference).to be_in_submission_phase
      end

      it 'should return false if date is before start deadline' do
        DateTime.expects(:now).returns(@start - 1.second)

        expect(@conference).to_not be_in_submission_phase
      end

      it 'should return true if date is after start deadline' do
        DateTime.expects(:now).returns(@start + 1.second)

        expect(@conference).to be_in_submission_phase
      end

      it 'should return true if date is prior to end deadline' do
        DateTime.expects(:now).returns(@end - 1.second)

        expect(@conference).to be_in_submission_phase
      end

      it 'should return true if date is on end deadline' do
        DateTime.expects(:now).returns(@end)

        expect(@conference).to be_in_submission_phase
      end

      it 'should return false if date is after end deadline' do
        DateTime.expects(:now).returns(@end + 1.second)

        expect(@conference).to_not be_in_submission_phase
      end

      it 'should return false if start is nil' do
        @conference.submissions_open = nil

        expect(@conference).to_not be_in_submission_phase
      end

      it 'should return false if end is nil' do
        @conference.submissions_deadline = nil

        expect(@conference).to_not be_in_submission_phase
      end
    end

    describe 'in_early_review_phase?' do
      before(:each) do
        @conference = FactoryGirl.build(:conference)
        @start = @conference.presubmissions_deadline
        @end = @conference.prereview_deadline
      end

      it 'should return true if date is on start deadline' do
        DateTime.expects(:now).returns(@start)

        expect(@conference).to be_in_early_review_phase
      end

      it 'should return false if date is before start deadline' do
        DateTime.expects(:now).returns(@start - 1.second)

        expect(@conference).to_not be_in_early_review_phase
      end

      it 'should return true if date is after start deadline' do
        DateTime.expects(:now).returns(@start + 1.second)

        expect(@conference).to be_in_early_review_phase
      end

      it 'should return true if date is prior to end deadline' do
        DateTime.expects(:now).returns(@end - 1.second)

        expect(@conference).to be_in_early_review_phase
      end

      it 'should return true if date is on end deadline' do
        DateTime.expects(:now).returns(@end)

        expect(@conference).to be_in_early_review_phase
      end

      it 'should return false if date is after end deadline' do
        DateTime.expects(:now).returns(@end + 1.second)

        expect(@conference).to_not be_in_early_review_phase
      end

      it 'should return false if start is nil' do
        @conference.presubmissions_deadline = nil

        expect(@conference).to_not be_in_early_review_phase
      end

      it 'should return false if end is nil' do
        @conference.prereview_deadline = nil

        expect(@conference).to_not be_in_early_review_phase
      end
    end

    describe 'in_final_review_phase?' do
      before(:each) do
        @conference = FactoryGirl.build(:conference)
        @start = @conference.submissions_deadline
        @end = @conference.review_deadline
      end

      it 'should return true if date is on start deadline' do
        DateTime.expects(:now).returns(@start)

        expect(@conference).to be_in_final_review_phase
      end

      it 'should return false if date is before start deadline' do
        DateTime.expects(:now).returns(@start - 1.second)

        expect(@conference).to_not be_in_final_review_phase
      end

      it 'should return true if date is after start deadline' do
        DateTime.expects(:now).returns(@start + 1.second)

        expect(@conference).to be_in_final_review_phase
      end

      it 'should return true if date is prior to end deadline' do
        DateTime.expects(:now).returns(@end - 1.second)

        expect(@conference).to be_in_final_review_phase
      end

      it 'should return true if date is on end deadline' do
        DateTime.expects(:now).returns(@end)

        expect(@conference).to be_in_final_review_phase
      end

      it 'should return false if date is after end deadline' do
        DateTime.expects(:now).returns(@end + 1.second)

        expect(@conference).to_not be_in_final_review_phase
      end

      it 'should return false if start is nil' do
        @conference.submissions_deadline = nil

        expect(@conference).to_not be_in_final_review_phase
      end

      it 'should return false if end is nil' do
        @conference.review_deadline = nil

        expect(@conference).to_not be_in_final_review_phase
      end
    end

    describe 'in_author_confirmation_phase?' do
      before(:each) do
        @conference = FactoryGirl.build(:conference,
          author_notification: Time.now + 6.days,
          author_confirmation: Time.now + 10.days)
        @start = @conference.author_notification
        @end = @conference.author_confirmation
      end

      it 'should return true if date is on start deadline' do
        DateTime.expects(:now).returns(@start)

        expect(@conference).to be_in_author_confirmation_phase
      end

      it 'should return false if date is before start deadline' do
        DateTime.expects(:now).returns(@start - 1.second)

        expect(@conference).to_not be_in_author_confirmation_phase
      end

      it 'should return true if date is after start deadline' do
        DateTime.expects(:now).returns(@start + 1.second)

        expect(@conference).to be_in_author_confirmation_phase
      end

      it 'should return true if date is prior to end deadline' do
        DateTime.expects(:now).returns(@end - 1.second)

        expect(@conference).to be_in_author_confirmation_phase
      end

      it 'should return true if date is on end deadline' do
        DateTime.expects(:now).returns(@end)

        expect(@conference).to be_in_author_confirmation_phase
      end

      it 'should return false if date is after end deadline' do
        DateTime.expects(:now).returns(@end + 1.second)

        expect(@conference).to_not be_in_author_confirmation_phase
      end

      it 'should return false if start is nil' do
        @conference.author_notification = nil

        expect(@conference).to_not be_in_author_confirmation_phase
      end

      it 'should return false if end is nil' do
        @conference.author_confirmation = nil

        expect(@conference).to_not be_in_author_confirmation_phase
      end
    end

    it 'should not fail if conference does not have early review' do
      conference = FactoryGirl.build(:conference)
      DateTime.stubs(:now).returns(conference.submissions_open)
      expect(conference).to_not be_in_early_review_phase
    end

    describe 'in_voting_deadline?' do
      before do
        @conference = FactoryGirl.build(:conference)
        @conference.voting_deadline = @conference.submissions_deadline + 5.days
      end

      it 'should be true if date is prior to voting deadline' do
        DateTime.stubs(:now).returns(@conference.voting_deadline - 1.second)

        expect(@conference).to be_in_voting_phase
      end

      it 'should be true if date is on voting deadline' do
        DateTime.stubs(:now).returns(@conference.voting_deadline)

        expect(@conference).to be_in_voting_phase
      end

      it 'should be false if date is after voting deadline' do
        DateTime.stubs(:now).returns(@conference.voting_deadline + 1.second)

        expect(@conference).to_not be_in_voting_phase
      end

      it 'should be false if conference does not have a voting deadline' do
        conference = FactoryGirl.build(:conference)
        conference.voting_deadline = nil
        expect(conference).to_not be_in_voting_phase
      end
    end
  end

  describe '#ideal_reviews_burn' do
    let(:conference) { FactoryGirl.create :conference_in_review_time }
    context 'when the conference does not have submissions' do
      it { expect(conference.ideal_reviews_burn).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    end

    context 'when the conference has submissions' do
      context 'and the submissions count fits the remaining weeks to do the reviews' do
        let!(:session_list) { FactoryGirl.create_list(:session, 18, conference: conference) }
        it { expect(conference.ideal_reviews_burn).to eq [54, 48, 42, 36, 30, 24, 18, 12, 6, 0] }
      end

      context 'and the remaining weeks are bigger than the reviews needed' do
        let!(:session_list) { FactoryGirl.create_list(:session, 2, conference: conference) }
        it { expect(conference.ideal_reviews_burn).to eq [6, 5, 4, 3, 2, 1, 0, 0, 0, 0] }
      end

      context 'and the remaining weeks are smaller than the reviews needed' do
        let!(:session_list) { FactoryGirl.create_list(:session, 20, conference: conference) }
        it { expect(conference.ideal_reviews_burn).to eq [60, 54, 48, 42, 36, 30, 24, 18, 12, 6] }
      end
    end
  end

  describe '#actual_reviews_burn' do
    let(:conference) { FactoryGirl.create :conference_in_review_time }
    context 'when the conference does not have submissions' do
      it { expect(conference.ideal_reviews_burn).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
    end

    context 'when the conference has submissions' do
      context 'and less reviews than the total required' do
        let!(:session_list) { FactoryGirl.create_list(:session, 4, conference: conference) }
        let!(:review_list) { FactoryGirl.create_list(:final_review, 4, session: session_list.first, created_at: 3.weeks.ago) }
        let!(:other_review_list) { FactoryGirl.create_list(:final_review, 7, session: session_list.second, created_at: 1.week.ago) }
        let!(:two_weeks_review_list) { FactoryGirl.create_list(:final_review, 15, session: session_list.second, created_at: Time.zone.now) }
        it { expect(conference.actual_reviews_burn).to eq [12, 8, 8, 1, 0] }
      end
    end
  end
end
