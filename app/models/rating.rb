# frozen_string_literal: true

class Rating < ApplicationRecord
  validates :title, presence: true

  has_many :agile_xp_reviews, foreign_key: 'author_agile_xp_rating_id', dependent: :restrict_with_exception, inverse_of: :author_agile_xp_rating
  has_many :proposal_xp_reviews, foreign_key: 'author_proposal_xp_rating_id', dependent: :restrict_with_exception, inverse_of: :author_proposal_xp_rating
  has_many :quality_reviews, foreign_key: 'proposal_quality_rating_id', dependent: :restrict_with_exception, inverse_of: :proposal_quality_rating
  has_many :relevance_reviews, foreign_key: 'proposal_relevance_rating_id', dependent: :restrict_with_exception, inverse_of: :proposal_relevance_rating
  has_many :confidence_reviews, foreign_key: 'reviewer_confidence_rating_id', dependent: :restrict_with_exception, inverse_of: :reviewer_confidence_rating
end
