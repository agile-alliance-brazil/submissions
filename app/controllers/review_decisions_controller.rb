# encoding: UTF-8
class ReviewDecisionsController < InheritedResources::Base
  singleton_belongs_to :session
  
  actions :new, :create, :edit, :update

  def index
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.js do
        render :json => {
          'required_decisions' => Session.for_conference(@conference).without_state(:cancelled).count,
          'total_decisions' => ReviewDecision.for_conference(@conference).count,
          'total_accepted' => ReviewDecision.for_conference(@conference).accepted.count,
          'total_confirmed' => ReviewDecision.for_conference(@conference).accepted.confirmed.count
        }
      end
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review_decision.create.success')
        redirect_to organizer_sessions_path(@conference)
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
        redirect_to organizer_sessions_path(@conference)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end
  
  protected
  def resource_params
    super.tap do |attributes|
      attributes.first[:organizer_id] = current_user.id
    end
  end
end
