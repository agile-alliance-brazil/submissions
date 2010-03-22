class Review < ActiveRecord::Base
  attr_accessible :author_agile_xp_rating_id, :author_proposal_xp_rating_id
  attr_accessible :proposal_track, :proposal_level, :proposal_type, :proposal_duration, :proposal_limit, :proposal_abstract
  attr_accessible :proposal_quality_rating_id, :proposal_relevance_rating_id
  attr_accessible :recommendation_id, :justification
  attr_accessible :reviewer_confidence_rating_id
  attr_accessible :comments_to_organizers, :comments_to_authors
  attr_accessible :reviewer_id, :session_id
  
  attr_trimmed :comments_to_organizers, :comments_to_authors, :justification
  
  belongs_to :reviewer
  belongs_to :session
  has_many :ratings
  has_one :recommendation
end