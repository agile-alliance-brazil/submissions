class ReviewsListingController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to :action => :reviewer
      end
      format.js do
        render :json => {
          'required_reviews' => Session.without_state(:cancelled).count * 3,
          'total_reviews' => Review.count
        }
      end
    end
  end
  
  def reviewer
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column] || 'created_at')
    order = "reviews.#{column} #{direction}"
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= order
    @reviews = current_user.reviews.paginate(paginate_options)
  end
end