# encoding: UTF-8
class ReviewFeedbacksController < ApplicationController
  def new
    @review_feedback = build_review_feedback
    add_evaluations_for(@review_feedback)
    render :new
  end

  def create
    @review_feedback = build_review_feedback(feedback_parameters)
    if @review_feedback.save
      flash[:notice] = I18n.t('flash.review_feedback.create.success')
      redirect_to root_url(@review_feedback.conference)
    else
      add_evaluations_for(@review_feedback)
      flash[:error] = I18n.t('flash.failure')
      render :new
    end
  end

  def resource_class
    ReviewFeedback
  end

  private
  def build_review_feedback(attributes = {})
    review_feedback = ReviewFeedback.new(attributes)
    review_feedback.author = current_user
    review_feedback.conference = @conference
    review_feedback.review_evaluations.each do |evaluation|
      evaluation.review_feedback = review_feedback
    end
    review_feedback
  end

  def add_evaluations_for(review_feedback)
    reviews = current_user.sessions_for_conference(@conference).
      includes(final_reviews: [:session]).map(&:final_reviews).flatten
    missing_evaluation_reviews = reviews - review_feedback.review_evaluations.map(&:review)
    missing_evaluation_reviews.each do |review|
      review_feedback.review_evaluations.build(review: review, review_feedback: @review_feedback)
    end
    review_feedback.review_evaluations
  end

  def feedback_parameters
    params.require(:review_feedback).permit(
      :general_comments,
      review_evaluations_attributes: [:helpful_review, :review_id, :comments]
    )
  end
end
