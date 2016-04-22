# encoding: UTF-8
class ReviewsListingController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to reviewer_reviews_path(@conference)
      end
      format.js do
        if @conference.in_early_review_phase?
          sessions_to_review = Session.for_review_in(@conference).count
          sessions_without_reviews = Session.for_review_in(@conference).with_incomplete_early_reviews.count
          stats = {
            'required_reviews' => sessions_to_review,
            'total_reviews' => sessions_to_review - sessions_without_reviews
          }
        else
          stats = {
            'required_reviews' => Session.for_review_in(@conference).count * 3,
            'total_reviews' => FinalReview.for_conference(@conference).count
          }
        end

        render json: stats
      end
    end
  end

  def reviewer
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    order = "reviews.#{column} #{direction}"
    @reviews = current_user.reviews.
      for_conference(@conference).
      page(params[:page]).
      order(order).
      includes(session: [:author, :second_author, :track, { review_decision: :outcome }])
  end
end
