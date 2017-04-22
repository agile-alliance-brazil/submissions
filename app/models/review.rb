# encoding: UTF-8
# frozen_string_literal: true

class Review < ActiveRecord::Base
  attr_trimmed :comments_to_organizers, :comments_to_authors

  belongs_to :session # Just for joining (without counter cache)
  belongs_to :reviewer, class_name: 'User'
  belongs_to :author_agile_xp_rating, class_name: 'Rating'
  belongs_to :author_proposal_xp_rating, class_name: 'Rating'
  belongs_to :proposal_quality_rating, class_name: 'Rating'
  belongs_to :proposal_relevance_rating, class_name: 'Rating'
  belongs_to :reviewer_confidence_rating, class_name: 'Rating'
  belongs_to :recommendation # Early review doesn't have it but needs for feedbacks

  has_many :review_evaluations

  validates :author_agile_xp_rating_id, presence: true
  validates :author_proposal_xp_rating_id, presence: true
  validates :proposal_quality_rating_id, presence: true
  validates :proposal_relevance_rating_id, presence: true
  validates :reviewer_confidence_rating_id, presence: true
  validates :reviewer_id, presence: true, uniqueness: { scope: %i[session_id type] }
  validates :session_id, presence: true

  validates :proposal_track, inclusion: { in: [true, false] }
  validates :proposal_level, inclusion: { in: [true, false] }
  validates :proposal_type, inclusion: { in: [true, false] }
  validates :proposal_duration, inclusion: { in: [true, false] }
  validates :proposal_limit, inclusion: { in: [true, false] }
  validates :proposal_abstract, inclusion: { in: [true, false] }

  validates :comments_to_authors, length: { minimum: 150 }

  scope(:for_conference, ->(c) { joins(:session).where(sessions: { conference_id: c.id }) })
end
