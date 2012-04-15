# encoding: UTF-8
class ReviewsListingController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to reviewer_reviews_path(@conference)
      end
      format.js do
        stats = {}
        stats['required_reviews'] = Session.for_conference(@conference).without_state(:cancelled).count
        stats['required_reviews'] = stats['required_reviews'] * 3 if @conference.in_final_review_phase?

        stats['total_reviews'] = @conference.in_early_review_phase? ?
          EarlyReview.for_conference(@conference).count :
          FinalReview.for_conference(@conference).count

        render :json => stats
      end
    end
  end

  def reviewer
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    order = "reviews.#{column} #{direction}"
    @reviews = current_user.reviews.for_conference(@conference).page(params[:page]).order(order)
  end
end
