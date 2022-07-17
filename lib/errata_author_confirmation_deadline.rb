# frozen_string_literal: true

class ErrataAuthorConfirmationDeadline
  def publish
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with('ACCEPT:ERRATA', session)
    end
  end

  private

  def accepted_sessions
    sessions_with_outcome('outcomes.accept.title')
  end

  def try_with(action, session)
    EmailNotifications.notification_of_acceptance_errata(session).deliver_now
    Rails.logger.info("  [#{action}] OK session_id: #{session.id}")
  rescue StandardError => e
    Airbrake.notify(e.message, action: "Publish review errata with #{action}", session: session)
    Rails.logger.info("  [FAILED #{action}] session_id: #{session.id} #{e.message}")
  ensure
    Rails.logger.flush
  end

  def sessions_with_outcome(outcome_title)
    outcome = Outcome.find_by(title: outcome_title)
    s = Session.for_conference(current_conference)
    s.includes(:review_decision).where(review_decisions: { outcome_id: outcome.id, published: true })
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
