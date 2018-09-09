# frozen_string_literal: true

require 'spec_helper'

describe ReviewPublisher do
  before do
    Session.stubs(:count).returns(0)
    EmailNotifications.stubs(:notification_of_acceptance).returns(stub(deliver_now: true))
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)

    # TODO: Improve conference usage
    @conference = FactoryBot.create(:conference)
    Conference.stubs(:current).returns(@conference)

    @reject_outcome = Outcome.find_by(title: 'outcomes.reject.title') || FactoryBot.create(:rejected_outcome)
    @backup_outcome = Outcome.find_by(title: 'outcomes.backup.title') || FactoryBot.create(:backup_outcome)
    @accept_outcome = Outcome.find_by(title: 'outcomes.accept.title') || FactoryBot.create(:accepted_outcome)

    @publisher = described_class.new
  end

  it 'raises error if there are sessions not reviewed' do
    sessions = [FactoryBot.build(:session), FactoryBot.build(:session)]
    Session.expects(:not_reviewed_for).with(@conference).returns(sessions)
    expect(-> { @publisher.publish }).to raise_error("There are #{sessions.size} sessions not reviewed: #{sessions.map(&:id)}")
  end

  context 'validating sessions without decision' do
    it 'raises error if sessions in_review' do
      sessions = [FactoryBot.build(:session), FactoryBot.build(:session), FactoryBot.build(:session)]
      Session.expects(:not_decided_for).with(@conference).returns(sessions)
      expect(-> { @publisher.publish }).to raise_error("There are #{sessions.size} sessions without decision: #{sessions.map(&:id)}")
    end

    it "raises error if reviewed sessions don't have decisions" do
      sessions = [FactoryBot.build(:session), FactoryBot.build(:session), FactoryBot.build(:session), FactoryBot.build(:session)]
      Session.expects(:without_decision_for).with(@conference).returns(sessions)
      expect(-> { @publisher.publish }).to raise_error("There are #{sessions.size} sessions without decision: #{sessions.map(&:id)}")
    end
  end

  context 'Sessions are all reviewed' do
    before do
      @publisher.stubs(:ensure_all_sessions_reviewed)
      @publisher.stubs(:ensure_all_decisions_made)
      @sessions = [in_review_session_for(@conference), in_review_session_for(@conference)]
      FactoryBot.create(:review_decision, session: @sessions[0])
      FactoryBot.create(:review_decision, session: @sessions[1])
      Session.stubs(:for_conference).returns(stub(with_outcome: @sessions))
    end

    def expect_acceptance(accept_or_reject)
      mock = mock()
      Session.stubs(:for_conference).returns(mock)
      mock.expects(:with_outcome).with(@accept_outcome).returns(accept_or_reject == :accept ? @sessions : [])
      mock.expects(:with_outcome).with(@backup_outcome).returns(accept_or_reject == :backup ? @sessions : [])
      mock.expects(:with_outcome).with(@reject_outcome).returns(accept_or_reject == :reject ? @sessions : [])
    end

    it 'sends reject e-mails' do
      expect_acceptance(:reject)

      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).with(@sessions[1]).returns(mock(deliver_now: true))

      @publisher.publish
    end

    it 'sends backup e-mails' do
      expect_acceptance(:backup)

      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).with(@sessions[1]).returns(mock(deliver_now: true))

      @publisher.publish
    end

    it 'sends acceptance e-mails' do
      expect_acceptance(:accept)

      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).with(@sessions[1]).returns(mock(deliver_now: true))

      @publisher.publish
    end

    it 'marks review decisions as published' do
      @publisher.publish
      expect(@sessions.map(&:review_decision).all?(&:published?)).to be true
    end

    it 'sends reject e-mails before acceptance e-mails' do
      notifications = sequence('notification')

      EmailNotifications.expects(:notification_of_acceptance)
                        .with(@sessions[0])
                        .with(@sessions[1])
                        .with(@sessions[0])
                        .with(@sessions[1])
                        .in_sequence(notifications)
                        .returns(mock(deliver_now: true))

      @publisher.publish
    end

    it 'logs rejected e-mails sent' do
      expect_acceptance(:reject)

      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      ::Rails.logger.expects(:info).times(2).with('  [REJECT] OK')

      @publisher.publish
    end

    it 'logs backup e-mails sent' do
      expect_acceptance(:backup)

      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      ::Rails.logger.expects(:info).times(2).with('  [BACKUP] OK')

      @publisher.publish
    end

    it 'logs accepted e-mails sent' do
      expect_acceptance(:accept)

      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      ::Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      ::Rails.logger.expects(:info).times(2).with('  [ACCEPT] OK')

      @publisher.publish
    end

    it 'captures error when notifying acceptance and move on' do
      expect_acceptance(:accept)

      error = StandardError.new('error')
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[1]).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with('  [FAILED ACCEPT] error')
      ::Rails.logger.expects(:info).with('  [ACCEPT] OK')
      Airbrake.expects(:notify).with('error', action: 'Publish review with ACCEPT', session: @sessions[0])

      @publisher.publish
    end

    it 'captures error when notifying backup and move on' do
      expect_acceptance(:backup)

      error = StandardError.new('error')
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[1]).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with('  [FAILED BACKUP] error')
      ::Rails.logger.expects(:info).with('  [BACKUP] OK')
      Airbrake.expects(:notify).with('error', action: 'Publish review with BACKUP', session: @sessions[0])

      @publisher.publish
    end

    it 'captures error when notifying rejection and move on' do
      expect_acceptance(:reject)

      error = StandardError.new('error')
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:notification_of_acceptance).with(@sessions[1]).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with('  [FAILED REJECT] error')
      ::Rails.logger.expects(:info).with('  [REJECT] OK')
      Airbrake.expects(:notify).with('error', action: 'Publish review with REJECT', session: @sessions[0])

      @publisher.publish
    end

    it 'flushes log at the end' do
      ::Rails.logger.expects(:flush)

      @publisher.publish
    end
  end

  def in_review_session_for(conference)
    FactoryBot.create(:session, conference: conference).tap(&:reviewing)
  end
end
