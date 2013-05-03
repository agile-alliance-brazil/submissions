# encoding: UTF-8
class FinalReview < Review
  attr_accessible :recommendation_id, :justification

  attr_trimmed :justification

  belongs_to :session, :counter_cache => true
  belongs_to :recommendation

  validates :recommendation_id, :presence => true
  validates :justification, :presence => { :unless => :strong_accept? }

  after_create do
    session.reviewing
  end

  private
  def strong_accept?
    self.recommendation.try(:title) == 'recommendation.strong_accept.title'
  end
end