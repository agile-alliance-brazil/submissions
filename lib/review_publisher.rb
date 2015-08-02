# encoding: UTF-8
class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
    rejected_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("REJECT", session)
    end
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("ACCEPT", session)
    end
  end

  private
  def ensure_all_sessions_reviewed
    not_reviewed_count = Session.not_reviewed_count_for(current_conference)
    raise "There are #{not_reviewed_count} sessions not reviewed" if not_reviewed_count > 0
  end

  def ensure_all_decisions_made
    not_decided_count = Session.not_decided_count_for(current_conference)
    raise "There are #{not_decided_count} sessions without decision" if not_decided_count > 0

    missing_decision = Session.without_decision_count_for(current_conference)
    raise "There are #{missing_decision} sessions without decision" if missing_decision > 0
  end

  def rejected_sessions
    sessions_with_outcome('outcomes.reject.title')
  end

  def accepted_sessions
    sessions_with_outcome('outcomes.accept.title')
  end

  def try_with(action, session)
    EmailNotifications.notification_of_acceptance(session).deliver_now
    session.review_decision.update_attribute(:published, true)
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end

  def sessions_with_outcome(outcome_title)
    outcome = Outcome.find_by_title(outcome_title)
    s = Session.for_conference(current_conference)
    s.with_outcome(outcome)
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
