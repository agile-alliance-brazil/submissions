# encoding: UTF-8
class WithdrawSessionsController < ApplicationController
  before_filter :load_session

  def show
  end
  
  def update
    params[:session][:state_event] = 'reject' if params[:session]
    if @session.update_attributes(params[:session])
      flash[:notice] = t('flash.session.withdraw.success')
      redirect_to user_my_sessions_path(current_user)
    else
      flash.now[:error] = t('flash.failure')
      render :show
    end
  end
  
  protected
  def load_session
    @session = Session.find(params[:session_id])
  end
end
