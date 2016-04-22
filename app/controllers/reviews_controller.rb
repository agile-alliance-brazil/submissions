# encoding: UTF-8
class ReviewsController < ApplicationController
  before_filter :load_session
  before_filter :load_review, only: [:edit, :update]

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
      flash[:notice] = t('flash.review.create.success')
      redirect_to session_review_path(@conference, @session, @review)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def update
    @review.update(review_params)
    redirect_to session_reviews_path(session_id: @session)
  end

  def show
    @review = resource
  end

  protected

  def load_session
    @session ||= Session.find(params[:session_id])
  end

  def review_params
    (params.permit(resource_request_name => [
      :author_agile_xp_rating_id,
      :author_proposal_xp_rating_id,
      :proposal_track,
      :proposal_level,
      :proposal_type,
      :proposal_duration,
      :proposal_limit,
      :proposal_abstract,
      :proposal_quality_rating_id,
      :proposal_relevance_rating_id,
      :recommendation_id,
      :justification,
      :reviewer_confidence_rating_id,
      :comments_to_organizers,
      :comments_to_authors
    ])[resource_request_name] || {}).merge(inferred_params)
  end

  def resource_request_name
    in_early_review_phase? ? :early_review : :final_review
  end

  def inferred_params
    {
      reviewer_id: current_user.id,
      session_id: params[:session_id]
    }
  end

  def resource
    EarlyReview.find_by_id(params[:id]) || FinalReview.find_by_id(params[:id])
  end

  def resource_class
    in_early_review_phase? ? EarlyReview : FinalReview
  end

  def collection
    resource_class.where(session_id: params[:session_id]).
      includes(:reviewer, :recommendation,
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
end
