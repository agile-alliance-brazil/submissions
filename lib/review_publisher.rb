class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
    rejected_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("REJECT") do
        EmailNotifications.notification_of_rejection(session).deliver
        session.review_decision.update_attribute(:published, true)
      end
    end
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("ACCEPT") do
        EmailNotifications.notification_of_acceptance(session).deliver
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
    HoptoadNotifier.notify(e)
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