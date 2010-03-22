class ReviewsController < InheritedResources::Base
  actions :index, :new, :create, :show
  respond_to :html
  
  belongs_to :session
end