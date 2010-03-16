class AcceptReviewersController < ApplicationController
  def show
  end
  
  def update
    if @reviewer.try(:accept)
      flash[:notice] = t('flash.reviewer.accept.success')
      redirect_to root_path
    else
      flash.now[:error] = t('flash.reviewer.accept.failure', :status => t("reviewer.state.#{@reviewer.state}"))
      render :show
    end
  end
  
  protected
  def authorize_action
    @reviewer = Reviewer.find(params[:reviewer_id])
    unauthorized! unless current_user == @reviewer.try(:user) && @reviewer.invited?
  end
end