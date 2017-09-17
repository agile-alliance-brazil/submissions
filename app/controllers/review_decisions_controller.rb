# frozen_string_literal: true

class ReviewDecisionsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        render json: {
          'required_decisions' => Session.for_conference(@conference).without_state(:cancelled).count,
          'total_decisions' => ReviewDecision.for_conference(@conference).count,
          'total_accepted' => ReviewDecision.for_conference(@conference).accepted.count,
          'total_confirmed' => ReviewDecision.for_conference(@conference).accepted.confirmed.count
        }
      end
    end
  end

  def new
    attributes = (params[:review_decision] || {}).merge(inferred_attributes)
    @review_decision = ReviewDecision.new(attributes)
  end

  def create
    @review_decision = ReviewDecision.new(decision_params)
    if @review_decision.save
      flash[:notice] = t('flash.review_decision.create.success')
      redirect_to organizer_sessions_path(@conference)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def edit
    @review_decision = resource
  end

  def update
    @review_decision = resource
    if @review_decision.update_attributes(decision_params)
      flash[:notice] = t('flash.review_decision.update.success')
      redirect_to organizer_sessions_path(@conference)
    else
      flash.now[:error] = t('flash.failure')
      render :edit
    end
  end

  protected

  def resource_class
    ReviewDecision
  end

  def resource
    ReviewDecision.includes(:session).find(params[:id])
  end

  def decision_params
    attributes = params.require(:review_decision)
                       .permit(:outcome_id, :note_to_authors)
    attributes.merge(inferred_attributes)
  end

  def inferred_attributes
    { organizer_id: @current_user.id, session_id: params[:session_id] }
  end
end
