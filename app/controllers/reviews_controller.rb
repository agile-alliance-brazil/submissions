# encoding: UTF-8
class ReviewsController < InheritedResources::Base
  actions :all, except: [:edit, :update, :destroy]
  respond_to :html

  belongs_to :session

  def index
    index! do |format|
      format.html { render :author }
    end
  end

  def organizer
    index! do |format|
      format.html { render :organizer }
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review.create.success')
        redirect_to session_review_path(@conference, @session, @review)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  def permitted_params
    params.permit(resource_request_name => [
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
      :comments_to_authors,
      :session_id
    ])
  end

  protected
  def collection
    @reviews ||= end_of_association_chain.
      includes(:reviewer, :recommendation, :reviewer_confidence_rating,
        :author_agile_xp_rating, :author_proposal_xp_rating,
        :proposal_quality_rating, :proposal_relevance_rating)
  end
  def resource_params
    super.tap do |attributes|
      attributes.first[:reviewer_id] = current_user.id
    end
  end

  def resource
    @review ||= Review.find(params[:id])
  end

  def resource_class
    in_early_review_phase? ? EarlyReview : FinalReview
  end

  def method_for_association_chain
    in_early_review_phase? ? :early_reviews : :final_reviews
  end

  def resource_request_name
    in_early_review_phase? ? :early_review : :final_review
  end

  private
  def in_early_review_phase?
    return params[:type] == 'early' if params[:type].present?
    @conference.in_early_review_phase?
  end
end
