class ConfirmSessionsController < ApplicationController
  def show
  end
  
  def update
    params[:session][:state_event] = 'accept' if params[:session]
    if @session.update_attributes(params[:session])
      flash[:notice] = t('flash.session.confirm.success')
      redirect_to user_my_sessions_path(current_user)
    else
      flash.now[:error] = t('flash.failure')
      render :show
    end
  end
  
  protected
  def authorize_action
    @session = Session.find(params[:session_id])
    unauthorized! unless @session.author == current_user && @session.pending_confirmation? && @session.review_decision && Time.zone.now <= Time.zone.local(2010, 6, 7, 23, 59, 59)
  end
end