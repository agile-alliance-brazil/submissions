# encoding: UTF-8
class ReviewFeedback < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :conference
  belongs_to :author, class_name: 'User'
  has_many :review_evaluations, inverse_of: :review_feedback
  accepts_nested_attributes_for :review_evaluations

  validates :conference, presence: true, existence: true
  validates :author, presence: true, existence: true
  validate :has_all_review_evaluations

  def has_all_review_evaluations
    has_reviews = author
    reviews_to_be_evaluated = author.nil? ? [] :
      author.sessions_for_conference(conference).
        includes(:final_reviews).map(&:final_review_ids).flatten
    evaluations_available = review_evaluations.map(&:review_id)
    unless (reviews_to_be_evaluated - evaluations_available).empty?
      errors.add(:review_evaluations, I18n.t('activerecord.errors.models.review_feedback.evaluations_missing'))
    end
  end
end