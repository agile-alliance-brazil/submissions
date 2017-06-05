# encoding: UTF-8
# frozen_string_literal: true

class ReviewEvaluation < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :review
  # TODO: validate presence
  belongs_to :review_feedback

  validates :review, presence: true, existence: true
  validate :review_matches_feedback

  def review_matches_feedback
    matches = review && review.session &&
              review.session.conference_id == review_feedback.conference_id &&
              review.session.authors.include?(review_feedback.author)
    errors.add(:review, I18n.t('activerecord.errors.models.review_evaluation.review_and_feedback_missmatch')) unless matches
  end
end
