# encoding: UTF-8
# frozen_string_literal: true
class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
    rejected_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with('REJECT', session)
    end
    backup_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with('BACKUP', session)
    end
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with('ACCEPT', session)
    end
  end

  private

  def ensure_all_sessions_reviewed
    not_reviewed_count = Session.not_reviewed_count_for(current_conference)
    raise "There are #{not_reviewed_count} sessions not reviewed" if not_reviewed_count.positive?
  end

  def ensure_all_decisions_made
    not_decided_count = Session.not_decided_count_for(current_conference)
    raise "There are #{not_decided_count} sessions without decision" if not_decided_count.positive?

    missing_decision = Session.without_decision_count_for(current_conference)
    raise "There are #{missing_decision} sessions without decision" if missing_decision.positive?
  end

  def rejected_sessions
    sessions_with_outcome('outcomes.reject.title')
  end

  def backup_sessions
    sessions_with_outcome('outcomes.backup.title')
  end

  def accepted_sessions
    sessions_with_outcome('outcomes.accept.title')
  end

  def try_with(action, session)
    EmailNotifications.notification_of_acceptance(session).deliver_now
    session.review_decision.update_attribute(:published, true)
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e.message, action: "Publish review with #{action}", session: session)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end

  def sessions_with_outcome(outcome_title)
    outcome = Outcome.find_by(title: outcome_title)
    s = Session.for_conference(current_conference)
    s.with_outcome(outcome)
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
