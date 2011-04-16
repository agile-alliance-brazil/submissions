class ReviewsListingController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to :action => :reviewer
      end
      format.js do
        render :json => {
          'required_reviews' => Session.for_conference(current_conference).without_state(:cancelled).count * 3,
          'total_reviews' => Review.for_conference(current_conference).count
        }
      end
    end
  end
  
  def reviewer
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    order = "reviews.#{column} #{direction}"
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= order
    @reviews = current_user.reviews.for_conference(current_conference).paginate(paginate_options)
  end
end