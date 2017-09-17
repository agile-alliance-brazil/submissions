# frozen_string_literal: true

class ReviewFeedback < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :conference
  belongs_to :author, class_name: 'User'
  has_many :review_evaluations, inverse_of: :review_feedback, dependent: :restrict_with_exception
  accepts_nested_attributes_for :review_evaluations

  validates :conference, presence: true, existence: true
  validates :author, presence: true, existence: true
  validate :has_all_review_evaluations

  def has_all_review_evaluations
    reviews_to_be_evaluated = if author.nil?
                                []
                              else
                                author.sessions_for_conference(conference)
                                      .includes(:final_reviews).map(&:final_review_ids).flatten
                              end
    evaluations_available = review_evaluations.map(&:review_id)

    missing_evaluations = reviews_to_be_evaluated - evaluations_available
    return if missing_evaluations.empty?

    error_message = I18n.t('activerecord.errors.models.review_feedback.evaluations_missing')
    errors.add(:review_evaluations, error_message)
  end
end
