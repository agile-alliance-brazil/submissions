# encoding: UTF-8
class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
    ensure_all_decisions_consistent_with_session_state
    rejected_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("REJECT") do
        EmailNotifications.send_notification_of_rejection(session)
        session.review_decision.update_attribute(:published, true)
      end
    end
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("ACCEPT") do
        EmailNotifications.send_notification_of_acceptance(session)
        session.review_decision.update_attribute(:published, true)
      end
    end
  end

  private
  def ensure_all_sessions_reviewed
    not_reviewed_count = Session.count(:conditions => ['state = ? AND conference_id = ?', 'created', current_conference.id])
    raise "There are #{not_reviewed_count} sessions not reviewed" if not_reviewed_count > 0
  end

  def ensure_all_decisions_made
    not_decided_count = Session.count(:conditions => ['state = ? AND conference_id = ?', 'in_review', current_conference.id])
    raise "There are #{not_decided_count} sessions without decision" if not_decided_count > 0

    missing_decision = Session.count(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
      :conditions => ['state IN (?) AND review_decision_count.cnt <> 1 AND conference_id = ?', ['pending_confirmation', 'rejected'], current_conference.id])
    raise "There are #{missing_decision} sessions without decision" if missing_decision > 0
  end

  def ensure_all_decisions_consistent_with_session_state
    accepted_in_wrong_state = Session.count(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  WHERE review_decisions.outcome_id = 1
                  GROUP BY session_id
                ) AS accepted_count
                ON accepted_count.session_id = sessions.id",
      :conditions => ['state NOT IN (?) AND accepted_count.cnt > 0 AND conference_id = ?', ['pending_confirmation', 'accepted'], current_conference.id])
    raise "There are #{accepted_in_wrong_state} accepted sessions with the wrong state" if accepted_in_wrong_state > 0

    rejected_in_wrong_state = Session.count(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  WHERE review_decisions.outcome_id = 2
                  GROUP BY session_id
                ) AS rejected_count
                ON rejected_count.session_id = sessions.id",
      :conditions => ['state NOT IN (?) AND rejected_count.cnt > 0 AND conference_id = ?', ['rejected'], current_conference.id])
    raise "There are #{rejected_in_wrong_state} rejected sessions with the wrong state" if rejected_in_wrong_state > 0
  end

  def rejected_sessions
    sessions_with_outcome('outcomes.reject.title')
  end

  def accepted_sessions
    sessions_with_outcome('outcomes.accept.title')
  end

  def try_with(action, &blk)
    blk.call
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end

  def sessions_with_outcome(outcome)
    Session.all(
      :joins => :review_decision,
      :conditions => ['outcome_id = ? AND published = ? AND conference_id = ?', Outcome.find_by_title(outcome).id, false, current_conference.id]
    )
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
