# frozen_string_literal: true

class RejectReviewersController < ApplicationController
  before_action :load_reviewer

  def show; end

  def update
    if @reviewer.try(:reject)
      flash[:notice] = t('flash.reviewer.reject.success')
      redirect_to root_path
    else
      flash.now[:error] = t('flash.reviewer.reject.failure', status: t("reviewer.state.#{@reviewer.state}"))
      render :show
    end
  end

  protected

  def load_reviewer
    @reviewer = Reviewer.find(params[:reviewer_id])
  end
end
