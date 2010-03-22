class Review < ActiveRecord::Base
  attr_accessible :author_agile_experience, :author_proposal_experience
  attr_accessible :proposal_track, :proposal_level, :proposal_type, :proposal_duration, :proposal_limit, :proposal_abstract
  attr_accessible :proposal_quality, :proposal_relevance
  attr_accessible :final_review, :justification
  
  belongs_to :reviewer
  belongs_to :session
end