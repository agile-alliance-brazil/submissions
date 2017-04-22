# encoding: UTF-8
# frozen_string_literal: true

class ReviewFeedbacksController < ApplicationController
  before_action :bounce_if_already_created

  rescue_from ActiveRecord::RecordNotUnique do |_exception|
    flash[:error] = t('flash.review_feedback.new.failure')

    begin
      redirect_to :back
    rescue
      redirect_to root_path(@conference)
    end
  end

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
    reviews = current_user.sessions_for_conference(@conference)
                          .includes(final_reviews: [:session]).map(&:final_reviews).flatten
    missing_evaluation_reviews = reviews - review_feedback.review_evaluations.map(&:review)
    missing_evaluation_reviews.each do |review|
      review_feedback.review_evaluations.build(review: review, review_feedback: @review_feedback)
    end
    review_feedback.review_evaluations
  end

  def feedback_parameters
    params.require(:review_feedback).permit(
      :general_comments,
      review_evaluations_attributes: %i[helpful_review review_id comments]
    )
  end

  def bounce_if_already_created
    feedback_exists = ReviewFeedback.exists?(
      conference_id: @conference,
      author_id: current_user
    )

    return unless feedback_exists

    error_message = %(ReviewFeedback for conference id "#{@conference.id} and \
user id #{current_user.id} already exists)
    raise ActiveRecord::RecordNotUnique.new(error_message, nil)
  end
end
