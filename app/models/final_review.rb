# frozen_string_literal: true

class FinalReview < Review
  attr_trimmed :justification

  belongs_to :session, counter_cache: true

  validates :recommendation_id, presence: true
  validates :justification, presence: { unless: :strong_accept? }

  after_create do
    session.reviewing
  end

  Recommendation.all_names.each do |type|
    define_method("#{type}?") do
      recommendation.try(:"#{type}?")
    end
    # Generates
    # def strong_accept?
    #   recommendation.try(:strong_accept?)
    # end
  end
end
