class ReviewDecisionsController < InheritedResources::Base
  belongs_to :session, :singleton => true
  
  actions :new, :create, :edit, :update
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review_decision.create.success')
        redirect_to organizer_sessions_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review_decision.update.success')
        redirect_to organizer_sessions_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end
  
  protected
  def build_resource
    attributes = params[:review_decision] || {}
    attributes[:organizer_id] = current_user.id
    @review_decision ||= end_of_association_chain.send(method_for_build, attributes)
  end
end