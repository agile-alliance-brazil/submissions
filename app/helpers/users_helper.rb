# frozen_string_literal: true

module UsersHelper
  def previous_sessions(latest_conference, user, current_user)
    old_sessions = user.sessions.includes(:final_reviews).reject do |s|
      s.conference == latest_conference
    end
    old_sessions.map do |s|
      text = s.title
      if current_user == user || current_user.organizer_for_conference(latest_conference)
        reviews = s.final_reviews.map { |r| r.recommendation.to_utf_chars }.join(', ')
        text += " (#{I18n.t("session.state.#{s.state}")} - #{reviews})".html_safe
      end
      link_to text, session_path(s.conference, s)
    end
  end
end
