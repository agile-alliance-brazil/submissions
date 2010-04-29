class ReviewPublisher
  def publish
    ensure_all_sessions_reviewed
    ensure_all_decisions_made
  end
  
  private
  def ensure_all_sessions_reviewed
    not_reviewed_count = Session.count(:conditions => ['state = ?', 'created'])
    raise "There are #{not_reviewed_count} sessions not reviewed" if not_reviewed_count > 0
  end
  
  def ensure_all_decisions_made
    missing_decision = Session.count(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
      :conditions => ['state = ? AND review_decision_count.cnt = 0', 'in_review'])
    raise "There are #{missing_decision} sessions without decision" if missing_decision > 0
  end
end