# encoding: UTF-8
# frozen_string_literal: true
class ReviewFeedbackRequester
  def send
    ensure_all_sessions_published
    authors_for(current_conference).each do |author|
      Rails.logger.info("[USER] #{author.to_param}")
      try_with(author)
    end
  end

  private

  def ensure_all_sessions_published
    not_published_count = Session.joins(:review_decision).where(['review_decisions.published = ? AND sessions.conference_id = ?', false, current_conference.id]).count
    raise "There are #{not_published_count} sessions not published" if not_published_count.positive?
  end

  def try_with(author)
    EmailNotifications.review_feedback_request(author).deliver_now
    Rails.logger.info('  [REQUEST FEEDBACK] OK')
  rescue => e
    Airbrake.notify(e.message, action: 'request review feedback', author: author)
    Rails.logger.info("  [FAILED REQUEST FEEDBACK] #{e.message}")
  ensure
    Rails.logger.flush
  end

  def authors_for(conference)
    Session.for_review_in(conference).map(&:authors).flatten.uniq.compact
  end

  def current_conference
    @current_conference ||= Conference.current
  end
end
