class ReviewsController < InheritedResources::Base
  actions :new, :create, :show
  respond_to :html

  belongs_to :session
  
  def index
    respond_to do |format|
      format.js do
        render :json => {
          'required_reviews' => Session.without_state(:cancelled).count * 3,
          'total_reviews' => Review.count
        }
      end
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review.create.success')
        redirect_to session_review_path(@session, @review)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  protected
  def build_resource
    attributes = params[:review] || {}
    attributes[:reviewer_id] = current_user.id
    @review ||= end_of_association_chain.send(method_for_build, attributes)
  end
end