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
    not_reviewed = Session.not_reviewed_for(current_conference)
    raise "There are #{not_reviewed.count} sessions not reviewed: #{not_reviewed.map(&:id)}" if not_reviewed.count.positive?
  end

  def ensure_all_decisions_made
    not_decided = Session.not_decided_for(current_conference)
    raise "There are #{not_decided.count} sessions without decision: #{not_decided.map(&:id)}" if not_decided.count.positive?

    missing_decision = Session.without_decision_for(current_conference)
    raise "There are #{missing_decision.count} sessions without decision: #{missing_decision.map(&:id)}" if missing_decision.count.positive?
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
    decision = session.review_decision
    decision.published = true
    decision.save!
    Rails.logger.info("  [#{action}] OK")
  rescue StandardError => e
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
