# encoding: UTF-8
require 'spec_helper'

describe ReviewPublisher do
  before(:each) do
    Session.stubs(:count).returns(0)
    EmailNotifications.stubs(:notification_of_acceptance).returns(stub(deliver_now: true))
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)

    # TODO: Improve conference usage
    @conference = FactoryGirl.create(:conference)
    Conference.stubs(:current).returns(@conference)

    # TODO outcome is a mess as it depends on having only those two values. Need to figure out something better
    @reject_outcome =Outcome.find_by_title('outcomes.reject.title') || FactoryGirl.create(:rejected_outcome)
    @accept_outcome = Outcome.find_by_title('outcomes.accept.title') || FactoryGirl.create(:accepted_outcome)

    @publisher = ReviewPublisher.new
  end

  it "should raise error if there are sessions not reviewed" do
    Session.expects(:count).with(conditions: ['state = ? AND conference_id = ?', 'created', @conference.id]).returns(2)
    expect(lambda {@publisher.publish}).to raise_error("There are 2 sessions not reviewed")
  end

  context "validating sessions without decision" do
    it "should raise error if sessions in_review" do
      Session.expects(:count).with(conditions: ['state = ? AND conference_id = ?', 'in_review', @conference.id]).returns(3)
      expect(lambda {@publisher.publish}).to raise_error("There are 3 sessions without decision")
    end

    it "should raise error if reviewed sessions don't have decisions" do
      Session.expects(:count).with(
        joins: "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
        conditions: ['state IN (?) AND review_decision_count.cnt <> 1 AND conference_id = ?', ['pending_confirmation', 'rejected'], @conference.id]).
        returns(4)
      expect(lambda {@publisher.publish}).to raise_error("There are 4 sessions without decision")
    end
  end

  context "Sessions are all reviewed" do
    before(:each) do
      @publisher.stubs(:ensure_all_sessions_reviewed)
      @publisher.stubs(:ensure_all_decisions_made)
      @sessions = [in_review_session_for(@conference), in_review_session_for(@conference)]
      FactoryGirl.create(:review_decision, session: @sessions[0])
      FactoryGirl.create(:review_decision, session: @sessions[1])
      Session.stubs(:all).returns(@sessions)
    end

    def expect_acceptance(accept_or_reject)
      Session.expects(:all).with(
        joins: :review_decision,
        conditions: ['outcome_id = ? AND published = ? AND conference_id = ?', @accept_outcome.id, false, @conference.id]).
        returns(accept_or_reject == :accept ? @sessions : [])
      Session.expects(:all).with(
        joins: :review_decision,
        conditions: ['outcome_id = ? AND published = ? AND conference_id = ?', @reject_outcome.id, false, @conference.id]).
        returns(accept_or_reject == :reject ? @sessions : [])
    end

    it "should send reject e-mails" do
      expect_acceptance(:reject)

      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).with(@sessions[1]).returns(mock(deliver_now: true))

      @publisher.publish
    end

    it "should send acceptance e-mails" do
      expect_acceptance(:accept)

      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).with(@sessions[1]).returns(mock(deliver_now: true))

      @publisher.publish
    end

    it "should mark review decisions as published" do
      @publisher.publish
      expect(@sessions.map(&:review_decision).all? {|r| r.published?}).to be true
    end

    it "should send reject e-mails before acceptance e-mails" do
      notifications = sequence('notification')

      EmailNotifications.expects(:notification_of_acceptance).
        with(@sessions[0]).
        with(@sessions[1]).
        with(@sessions[0]).
        with(@sessions[1]).
        in_sequence(notifications).
        returns(mock(deliver_now: true))

      @publisher.publish
    end

    it "should log rejected e-mails sent" do
      expect_acceptance(:reject)

      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      ::Rails.logger.expects(:info).times(2).with("  [REJECT] OK")

      @publisher.publish
    end

    it "should log accepted e-mails sent" do
      expect_acceptance(:accept)

      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      ::Rails.logger.expects(:info).times(2).with("  [ACCEPT] OK")

      @publisher.publish
    end

    it "should capture error when notifying acceptance and move on" do
      expect_acceptance(:accept)

      error = StandardError.new('error')
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[1]).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with("  [FAILED ACCEPT] error")
      ::Rails.logger.expects(:info).with("  [ACCEPT] OK")
      Airbrake.expects(:notify).with(error)

      @publisher.publish
    end

    it "should capture error when notifying rejection and move on" do
      expect_acceptance(:reject)

      error = StandardError.new('error')
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[1]).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with("  [FAILED REJECT] error")
      ::Rails.logger.expects(:info).with("  [REJECT] OK")
      Airbrake.expects(:notify).with(error)

      @publisher.publish
    end

    it "should flush log at the end" do
      ::Rails.logger.expects(:flush)

      @publisher.publish
    end
  end

  def in_review_session_for(conference)
    FactoryGirl.create(:session, conference: conference).tap(&:reviewing)
  end
end
