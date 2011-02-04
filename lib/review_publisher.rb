class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
    rejected_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("REJECT") { EmailNotifications.notification_of_rejection(session).deliver }
    end
    accepted_sessions.each do |session|
      Rails.logger.info("[SESSION] #{session.to_param}")
      try_with("ACCEPT") { EmailNotifications.notification_of_acceptance(session).deliver }
    end
    Rails.logger.flush
  end
  
  private
  def ensure_all_sessions_reviewed
    not_reviewed_count = Session.count(:conditions => ['state = ?', 'created'])
    raise "There are #{not_reviewed_count} sessions not reviewed" if not_reviewed_count > 0
  end
  
  def ensure_all_decisions_made
    not_decided_count = Session.count(:conditions => ['state = ?', 'in_review'])
    raise "There are #{not_decided_count} sessions without decision" if not_decided_count > 0

    missing_decision = Session.count(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
      :conditions => ['state IN (?) AND review_decision_count.cnt <> 1', ['pending_confirmation', 'rejected']])
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
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  end
  
  def sessions_with_outcome(outcome)
    Session.all(
      :joins => :review_decision,
      :conditions => ['outcome_id = ? AND published = ?', Outcome.find_by_title(outcome).id, false]
    )
  end
end