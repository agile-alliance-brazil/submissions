class Review < ActiveRecord::Base
  attr_accessible :author_agile_xp_rating_id, :author_proposal_xp_rating_id,
                  :proposal_track, :proposal_level, :proposal_type, :proposal_duration, :proposal_limit, :proposal_abstract,
                  :proposal_quality_rating_id, :proposal_relevance_rating_id,
                  :recommendation_id, :justification,
                  :reviewer_confidence_rating_id,
                  :comments_to_organizers, :comments_to_authors,
                  :reviewer_id, :session_id
  
  attr_trimmed :comments_to_organizers, :comments_to_authors, :justification
  
  belongs_to :reviewer
  belongs_to :session
  belongs_to :author_agile_xp_rating, :class_name => "Rating"
  belongs_to :author_proposal_xp_rating, :class_name => "Rating"
  belongs_to :proposal_quality_rating, :class_name => "Rating"
  belongs_to :proposal_relevance_rating, :class_name => "Rating"
  belongs_to :reviewer_confidence_rating, :class_name => "Rating"
  belongs_to :recommendation
  
  validates_presence_of :author_agile_xp_rating_id, :author_proposal_xp_rating_id,
                        :proposal_track, :proposal_level, :proposal_type, :proposal_duration, :proposal_limit, :proposal_abstract,
                        :proposal_quality_rating_id, :proposal_relevance_rating_id,
                        :recommendation_id,
                        :reviewer_confidence_rating_id,
                        :comments_to_organizers, :comments_to_authors,
                        :reviewer_id, :session_id

  validates_each :justification, :unless => :strong_accept? do |record, attr, value|
    record.errors.add(attr, :not_strong_acceptance_justification) if value.blank?
  end
  
  private
  def strong_accept?
    self.recommendation.try(:title) == 'recommendation.strong_accept.title'
  end
end