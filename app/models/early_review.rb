# encoding: UTF-8
class EarlyReview < Review
  belongs_to :session, :counter_cache => true
end