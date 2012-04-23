# encoding: UTF-8
class EarlyReview < Review
  belongs_to :session, :counter_cache => true

  after_create do
    notify
  end

  private
  def notify
    EmailNotifications.send_early_review_submitted(self.session)
  end
end