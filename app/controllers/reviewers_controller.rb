# encoding: UTF-8
class ReviewersController < ApplicationController
  respond_to :html, only: [:index, :show]
  respond_to :json, only: [:create, :destroy, :create_multiple]

  before_filter :load_reviewer_filter, only: :index
  has_scope :filtered, only: :index, as: :reviewer_filter, type: :hash do |controller, scope, value|
    controller.send(:load_reviewer_filter).apply(scope)
  end

  def index
    @tracks = @conference.tracks
    @states = resource_class.state_machine.states.map(&:name)
    @reviewers = apply_scopes(resource_class).
      for_conference(@conference).
      joins(:user).
      order('first_name, last_name').
      includes(user: [:reviews], accepted_preferences: [], conference: [])
    @reviewer_batch = ReviewerBatch.new(conference: @conference)
    @previous_reviewers = resource_class.
      where('conference_id != ? and user_id not in (?) and state = ?',
        @conference.id, @reviewers.map(&:user_id), :accepted).
      includes(user: [:reviews], conference: []).group_by(&:user)
    @reviewer = resource_class.new(conference: @conference)
  end

  def create
    reviewer = new_reviewer
    if reviewer.try(:save)
      render json: {
        message: t('flash.reviewer.create.success'),
        reviewer: ReviewerJsonBuilder.new(reviewer).to_json
      }.to_json, status: 201
    else
      message = t('flash.reviewer.create.failure', username: reviewer.try(:user_username))
      render json: message, status: 400
    end
  end

  def create_multiple
    batch = ReviewerBatch.new(batch_params.merge(conference: @conference))
    batch.save

    render json: batch.to_json, status: 200
  end

  def show
    @reviewer = Reviewer.where(id: params[:id]).
      includes(
        user: {
          reviews: {
            session: [:track],
            recommendation: [],
            review_evaluations: []
          }
        },
        conference: [], accepted_preferences: [:audience_level, :track]
      ).first
  end
    
  def destroy
    reviewer = resource_class.where(id: params[:id]).includes(:user).first
    if reviewer.nil?
      render json: 'not-found', status: 404
    else
      reviewer.destroy
      message = t('flash.reviewer.destroy.success', full_name: reviewer.user.full_name)
      render json: {message: message}.to_json, status: 200
    end
  end
  
  protected
  def resource_class
    Reviewer
  end

  def load_reviewer_filter
    @reviewer_filter ||= ReviewerFilter.new(params)
  end

  def new_reviewer
    if params[:reviewer]
      resource_class.new(new_reviewer_params).
        tap{|r| r.conference = @conference}
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
