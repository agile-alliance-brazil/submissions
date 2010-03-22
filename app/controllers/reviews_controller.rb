class ReviewsController < InheritedResources::Base
  actions :index, :new, :create, :show
  respond_to :html
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review.create.success')
        redirect_to session_path(@review)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
end