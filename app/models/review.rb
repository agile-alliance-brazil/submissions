# encoding: UTF-8
class Review < ActiveRecord::Base
  attr_accessible :author_agile_xp_rating_id, :author_proposal_xp_rating_id,
                  :proposal_track, :proposal_level, :proposal_type, :proposal_duration,
                  :proposal_limit, :proposal_abstract,
                  :proposal_quality_rating_id, :proposal_relevance_rating_id,
                  :reviewer_confidence_rating_id,
                  :comments_to_organizers, :comments_to_authors,
                  :reviewer_id, :session_id

  attr_trimmed :comments_to_organizers, :comments_to_authors

  belongs_to :session # Just for joining (without counter cache)
  belongs_to :reviewer, :class_name => "User"
  belongs_to :author_agile_xp_rating, :class_name => "Rating"
  belongs_to :author_proposal_xp_rating, :class_name => "Rating"
  belongs_to :proposal_quality_rating, :class_name => "Rating"
  belongs_to :proposal_relevance_rating, :class_name => "Rating"
  belongs_to :reviewer_confidence_rating, :class_name => "Rating"

  validates :author_agile_xp_rating_id, :presence => true
  validates :author_proposal_xp_rating_id, :presence => true
  validates :proposal_quality_rating_id, :presence => true
  validates :proposal_relevance_rating_id, :presence => true
  validates :reviewer_confidence_rating_id, :presence => true
  validates :reviewer_id, :presence => true, :uniqueness => { :scope => [:session_id, :type] }
  validates :session_id, :presence => true

  validates :proposal_track, :inclusion => { :in => [true, false] }
  validates :proposal_level, :inclusion => { :in => [true, false] }
  validates :proposal_type, :inclusion => { :in => [true, false] }
  validates :proposal_duration, :inclusion => { :in => [true, false] }
  validates :proposal_limit, :inclusion => { :in => [true, false] }
  validates :proposal_abstract, :inclusion => { :in => [true, false] }

  validates :comments_to_authors, :length => { :minimum => 150 }

  scope :for_conference, lambda { |c| joins(:session).where(:sessions => {:conference_id => c.id})}
end