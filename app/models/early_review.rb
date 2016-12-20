# encoding: UTF-8
# frozen_string_literal: true
class EarlyReview < Review
  belongs_to :session, counter_cache: true

  after_create do
    notify
  end

  private

  def notify
    EmailNotifications.early_review_submitted(session).deliver_now
  end
end
