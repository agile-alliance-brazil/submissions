class ReviewsListingController < ApplicationController
  def index
    if(current_user.reviewer)
      redirect_to :action => :reviewer
    else
      unauthorized!
    end
  end
  
  def reviewer
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'reviews.created_at DESC'
    @reviews = current_user.reviews.paginate(paginate_options)
  end
end