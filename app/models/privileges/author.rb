# encoding: utf-8
# frozen_string_literal: true

module Privileges
  class Author < Privileges::Base
    def privileges
      can!(:create, Session) do
        @conference.in_submission_phase?
      end
      can(:update, Session) do |session|
        session.try(:conference) == @conference && session.try(:is_author?, @user) && @conference.in_submission_phase?
      end
      can!(:index, EarlyReview) do |session|
        session.try(:is_author?, @user)
      end
      can!(:index, FinalReview) do |session|
        session.try(:is_author?, @user) && session.review_decision.try(:published?)
      end
      can(:manage, %w[confirm_sessions withdraw_sessions]) do
        @session.present? &&
          @session.is_author?(@user) &&
          @session.pending_confirmation? &&
          @session.review_decision &&
          @conference.in_author_confirmation_phase?
      end
      can!(:create, ReviewFeedback) do
        sessions = @user.sessions_for_conference(@conference)
                        .includes(:review_decision).reject(&:cancelled?)
        decisions = sessions.map(&:review_decision).compact
        !sessions.empty? &&
          decisions.size == sessions.size &&
          decisions.map(&:published?).all?
      end
    end
  end
end
