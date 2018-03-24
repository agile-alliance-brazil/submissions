# frozen_string_literal: true

class ReviewersController < ApplicationController
  def index
    filter_params = params.permit(reviewer_filter: %i[state track_id])
    @reviewer_filter = ReviewerFilter.new(filter_params)
    @tracks = @conference.tracks
    @states = resource_class.state_machine.states.map(&:name)
    @reviewers = @reviewer_filter.apply(Reviewer)
                                 .for_conference(@conference)
                                 .joins(:user)
                                 .order('first_name, last_name')
                                 .includes(user: [:reviews], accepted_preferences: [], conference: [])
    @reviewer_batch = ReviewerBatch.new(conference: @conference)
    @previous_reviewers = resource_class
                          .where('conference_id != ? and user_id not in (?) and state = ?',
                                 @conference.id, @reviewers.map(&:user_id), :accepted)
                          .includes(user: [:reviews], conference: []).group_by(&:user)
    @reviewer = resource_class.new(conference: @conference)
    respond_to do |format|
      format.html
    end
  end

  def create
    reviewer = new_reviewer
    if reviewer.try(:save)
      message = t('flash.reviewer.create.success')
      reviewer = ReviewerJsonBuilder.new(reviewer).to_json

      respond_to do |format|
        format.json do
          render json: {
            message: message,
            reviewer: reviewer
          }.to_json, status: :created
        end
      end
    else
      message = t('flash.reviewer.create.failure', username: reviewer.try(:user_username))
      respond_to do |format|
        format.json { render json: message, status: :bad_request }
      end
    end
  end

  def create_multiple
    batch = ReviewerBatch.new(batch_params.merge(conference: @conference))
    batch.save

    respond_to do |format|
      format.json { render json: batch.to_json, status: :ok }
    end
  end

  def show
    @reviewer = Reviewer.where(id: params[:id])
                        .includes(
                          user: {
                            reviews: {
                              session: [:track],
                              recommendation: [],
                              review_evaluations: []
                            }
                          },
                          conference: [], accepted_preferences: %i[audience_level track]
                        ).first
    respond_to do |format|
      format.html
    end
  end

  def destroy
    reviewer = resource_class.where(id: params[:id]).includes(:user).first
    if reviewer.nil?
      respond_to do |format|
        format.json { render json: 'not-found', status: :not_found }
      end
    else
      reviewer.destroy
      message = t('flash.reviewer.destroy.success', full_name: reviewer.user.full_name)
      respond_to do |format|
        format.json { render json: { message: message }.to_json, status: :ok }
      end
    end
  end

  protected

  def resource_class
    Reviewer
  end

  def new_reviewer
    return unless params[:reviewer]
    resource_class.new(new_reviewer_params).tap do |r|
      r.conference = @conference
    end
  end

  def new_reviewer_params
    params.require(:reviewer).permit(:user_username)
  end

  def batch_params
    params[:reviewer_batch].try(:[]=, :usernames, []) if params[:reviewer_batch].try(:[], :usernames).nil?
    params.require(:reviewer_batch).permit(usernames: [])
  end
end
