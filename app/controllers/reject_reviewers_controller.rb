class RejectReviewersController < ApplicationController
  before_filter :login_required
  
  def show
  end
  
  def update
    if @reviewer.try(:reject)
      flash[:notice] = t('flash.reviewer.reject.success')
      redirect_to root_path
    else
      flash.now[:error] = t('flash.reviewer.reject.failure', :status => t("reviewer.state.#{@reviewer.state}"))
      render :show
    end
  end
  
  protected
  def authorize_action
    @reviewer = Reviewer.find(params[:reviewer_id])
    unauthorized! unless current_user == @reviewer.try(:user) && @reviewer.invited?
  end
end