class ReviewListingController < InheritedResources::Base
  actions :index
  
  def reviewer
    render :reviewer
  end
end