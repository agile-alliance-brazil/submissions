# encoding: UTF-8
# frozen_string_literal: true

class ConfirmSessionsController < ApplicationController
  before_action :load_session

  def show; end

  def update
    attributes = session_params
    attributes[:state_event] = 'accept'
    if @session.update_attributes(attributes)
      flash[:notice] = t('flash.session.confirm.success')
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
    params.require(:session).permit(:author_agreement,
                                    :image_agreement, :title, :summary, :audience_limit)
  end
end
