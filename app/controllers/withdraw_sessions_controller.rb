# frozen_string_literal: true

class WithdrawSessionsController < ApplicationController
  before_action :load_session

  def show; end

  def update
    attributes = session_params
    attributes[:state_event] = 'reject'
    if @session.update(attributes)
      EmailNotifications.session_rejected(@session).deliver_now
      flash[:notice] = t('flash.session.withdraw.success')
      redirect_to user_sessions_path(@conference, current_user)
    else
      flash.now[:error] = t('flash.failure')
      render :show
    end
  end

  protected

  def load_session
    @session = Session.find(params[:session_id])
  end

  def session_params
    params.require(:session).permit(:author_agreement)
  end
end
