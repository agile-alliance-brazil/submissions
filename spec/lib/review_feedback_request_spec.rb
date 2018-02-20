# frozen_string_literal: true

require 'spec_helper'

describe ReviewFeedbackRequester do
  before(:each) do
    EmailNotifications.stubs(:review_feedback_request).returns(stub(deliver_now: true))
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)

    @conference = FactoryBot.create(:conference)
    Conference.stubs(:current).returns(@conference)

    @requester = ReviewFeedbackRequester.new
  end

  it 'should raise error if there are sessions not published' do
    Session.expects(:joins).with(:review_decision).returns(Session)
    Session.expects(:where).with(['review_decisions.published = ? AND sessions.conference_id = ?', false, @conference.id]).returns(Session)
    Session.expects(:count).returns(2)
    expect(-> { @requester.send }).to raise_error('There are 2 sessions not published')
  end

  context 'Sessions are all published' do
    before(:each) do
      @requester.stubs(:ensure_all_sessions_published)
      @sessions = [FactoryBot.create(:session), FactoryBot.create(:session)]
      FactoryBot.create(:review_decision, session: @sessions[0], published: true)
      FactoryBot.create(:review_decision, session: @sessions[1], published: true)
      Session.stubs(:for_review_in).returns(@sessions)
    end

    it 'should send feedback e-mails' do
      EmailNotifications.expects(:review_feedback_request).with(@sessions[0].author).with(@sessions[1].author).returns(mock(deliver_now: true))

      @requester.send
    end

    it 'should log e-mails sent' do
      ::Rails.logger.expects(:info).with("[USER] #{@sessions[0].author.to_param}")
      ::Rails.logger.expects(:info).with("[USER] #{@sessions[1].author.to_param}")
      ::Rails.logger.expects(:info).times(2).with('  [REQUEST FEEDBACK] OK')

      @requester.send
    end

    it 'should capture error when sending feedback request and move on' do
      error = StandardError.new('error')
      EmailNotifications.expects(:review_feedback_request).with(@sessions[0].author).raises(error)
      EmailNotifications.expects(:review_feedback_request).with(@sessions[1].author).returns(mock(deliver_now: true))

      ::Rails.logger.expects(:info).with('  [FAILED REQUEST FEEDBACK] error')
      ::Rails.logger.expects(:info).with('  [REQUEST FEEDBACK] OK')
      Airbrake.expects(:notify).with('error', action: 'request review feedback', author: @sessions[0].author)

      @requester.send
    end

    it 'should flush log at the end' do
      ::Rails.logger.expects(:flush)

      @requester.send
    end
  end
end
