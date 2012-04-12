# encoding: UTF-8
class ReviewsListingController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to reviewer_reviews_path(@conference)
      end
      format.js do
        render :json => {
          'required_reviews' => Session.for_conference(@conference).without_state(:cancelled).count * 3,
          'total_reviews' => FinalReview.for_conference(@conference).count
        }
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
