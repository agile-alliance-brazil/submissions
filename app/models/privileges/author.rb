# encoding: utf-8
class Privileges::Author < Privileges::Base
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
    can(:manage, ['confirm_sessions', 'withdraw_sessions']) do
      @session.present? &&
      @session.is_author?(@user) &&
      @session.pending_confirmation? &&
      @session.review_decision &&
      @conference.in_author_confirmation_phase?
    end
  end
end