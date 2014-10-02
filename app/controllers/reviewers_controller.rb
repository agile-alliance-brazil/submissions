# encoding: UTF-8
class ReviewersController < ApplicationController
  respond_to :html, only: [:index]
  respond_to :json, only: [:create, :destroy]

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
      includes(:user, :accepted_preferences)
    @previous_reviewers = [] || (resource_class.
      where('conference_id != ? and user_id not in (?)', @conference.id, @reviewers.map(&:user_id)).
      includes(:user, :accepted_preferences).all)
    @reviewer = resource_class.new(conference: @conference)
  end

  def create
    reviewer = resource_class.new(new_reviewer_params)
    reviewer.conference = @conference
    if reviewer.save
      render json: {
        message: t('flash.reviewer.create.success'),
        reviewer: build_simplified_reviewer_hash(reviewer)
      }.to_json, status: 201
    else
      message = t('flash.reviewer.create.failure', username: params[:reviewer][:user_username])
      render json: message, status: 400
    end
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

  def new_reviewer_params
    params.require(:reviewer).permit(:user_username)
  end

  def build_simplified_reviewer_hash(reviewer)
    {
      id: reviewer.id,
      full_name: reviewer.user.full_name,
      username: reviewer.user.username,
      status: t("reviewer.state.#{reviewer.state}"),
      url: reviewer_path(@conference, reviewer)
    }
  end
end
