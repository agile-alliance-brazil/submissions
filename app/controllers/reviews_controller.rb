# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :load_session
  before_action :load_review, only: %i[edit update]
  before_action :check_review_period, only: %i[edit update]

  def index
    @reviews = collection
    render :author
  end

  def organizer
    @reviews = collection
    render :organizer
  end

  def new
    @review = resource_class.new(review_params)
  end

  def create
    @review = resource_class.new(review_params)
    if @review.save
      create_third_reject(@review)
      flash[:notice] = t('flash.review.create.success')
      redirect_to session_review_path(@conference, @session, @review)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def edit; end

  def update
    if @review.update(review_params)
      redirect_to session_review_path(@conference, @session, @review), notice: t('reviews.update.success')
    else
      errors = @review.errors.messages.keys.map { |key| Review.human_attribute_name(key.to_sym) }
      flash[:alert] = t('errors.messages.invalid_form_data', value: errors.join(', '))
      render :edit
    end
  end

  def show
    @review = resource
  end

  protected

  def load_session
    @session = Session.find(params[:session_id])
  end

  def review_params
    (params.permit(resource_request_name => %i[
                     author_agile_xp_rating_id
                     author_proposal_xp_rating_id
                     proposal_track
                     proposal_level
                     proposal_type
                     proposal_duration
                     proposal_limit
                     proposal_abstract
                     proposal_quality_rating_id
                     proposal_relevance_rating_id
                     recommendation_id
                     justification
                     reviewer_confidence_rating_id
                     comments_to_organizers
                     comments_to_authors
                   ])[resource_request_name] || {}).merge(inferred_params)
  end

  def resource_request_name
    in_early_review_phase? ? :early_review : :final_review
  end

  def inferred_params
    p = {
      reviewer_id: current_user.id,
      session_id: params[:session_id]
    }
    p[:proposal_track] = true if @conference.single_track?
    p
  end

  def resource
    EarlyReview.find_by(id: params[:id]) || FinalReview.find_by(id: params[:id])
  end

  def resource_class
    in_early_review_phase? ? EarlyReview : FinalReview
  end

  def collection
    resource_class.where(session_id: params[:session_id])
                  .includes(:reviewer, :recommendation,
                            :reviewer_confidence_rating, :author_agile_xp_rating,
                            :author_proposal_xp_rating, :proposal_quality_rating,
                            :proposal_relevance_rating)
  end

  private

  def in_early_review_phase?
    return params[:type] == 'early' if params[:type].present?

    @conference.in_early_review_phase?
  end

  def load_review
    @review = resource
  end

  def check_review_period
    return if @conference.in_early_review_phase? || @conference.in_final_review_phase?

    redirect_to root_path, alert: t('reviews.edit.errors.conference_out_of_range')
  end

  def create_third_reject(review)
    return if in_early_review_phase?

    return unless review.weak_reject? || review.strong_reject?

    session_reviews = review.session.final_reviews
    return if session_reviews.count + 1 != 3

    first_review = session_reviews.reject { |r| r == review }.first
    return unless first_review.weak_reject? || first_review.strong_reject?

    justification = I18n.t('review.third_reject_auto_justification', conference_name: review.session.conference.name)

    resource_class.create!(
      session: review.session,
      recommendation: Recommendation.find_by(name: 'weak_reject'),
      reviewer_id: 3202,
      author_agile_xp_rating: Rating.find_low_instance,
      author_proposal_xp_rating: Rating.find_low_instance,
      proposal_quality_rating: Rating.find_low_instance,
      proposal_relevance_rating: Rating.find_low_instance,
      reviewer_confidence_rating: Rating.find_low_instance,
      proposal_track: false,
      proposal_level: false,
      proposal_type: false,
      proposal_duration: false,
      proposal_limit: false,
      proposal_abstract: false,
      comments_to_authors: justification,
      justification: justification
    )
  end
end
