class ReviewDecisionsController < InheritedResources::Base
  belongs_to :session, :singleton => true
  
  actions :new, :create, :edit, :update

  def index
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.js do
        render :json => {
          'required_decisions' => Session.for_conference(current_conference).without_state(:cancelled).count,
          'total_decisions' => ReviewDecision.for_conference(current_conference).count,
          'total_accepted' => ReviewDecision.for_conference(current_conference).accepted.count,
          'total_confirmed' => ReviewDecision.for_conference(current_conference).accepted.confirmed.count
        }
      end
    end
  end

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