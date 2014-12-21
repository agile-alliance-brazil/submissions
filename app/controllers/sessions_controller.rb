# encoding: UTF-8
class SessionsController < InheritedResources::Base
  actions :all, except: [:destroy]
  before_filter :load_user
  before_filter :load_tracks
  before_filter :load_audience_levels
  before_filter :load_session_types
  before_filter :load_tags, except: :show
  before_filter :load_comment, only: :show
  before_filter :check_conference, only: :show
  before_filter :load_session_filter, only: :index

  has_scope :for_user, only: :index, as: :user_id
  has_scope :filtered, only: :index, as: :session_filter, type: :hash do |controller, scope, value|
    controller.send(:load_session_filter).apply(scope)
  end

  def create
    create! do |success, failure|
      success.html do
        EmailNotifications.session_submitted(@session).deliver
        flash[:notice] = t('flash.session.create.success')
        redirect_to session_path(@conference, @session)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = t('flash.session.update.success')
        redirect_to session_path(@conference, @session)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end

  def cancel
    flash[:error] = t('flash.session.cancel.failure') unless resource.cancel
    redirect_to organizer_sessions_path(@conference)
  end

  protected
  def permitted_params
    params.permit(session: [
      :title, :summary, :description, :mechanics, :benefits,
      :target_audience, :prerequisites, :audience_level_id, :audience_limit,
      :author_id, :second_author_username, :track_id,
      :session_type_id, :duration_mins, :experience,
      :keyword_list, :language
    ])
  end

  def resource_params
    super.tap do |attributes|
      attributes.first[:conference_id] = @conference.id
    end
  end

  def load_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def load_comment
    @comment = Comment.new(user_id: current_user.id, commentable_id: @session.id)
  end

  def load_tracks
    @tracks ||= @conference.tracks
  end

  def load_audience_levels
    @audience_levels ||= @conference.audience_levels
  end

  def load_session_types
    @session_types ||= @conference.session_types
  end

  def load_session_filter
    @session_filter ||= SessionFilter.new(params)
  end

  def load_tags 
    @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
  end

  def check_conference
    if resource.conference != @conference
      flash.now[:news] = t('flash.news.session_different_conference',
        conference_name: resource.conference.name,
        current_conference_name: @conference.name).html_safe
    end
  end

  def collection
    @sessions ||= end_of_association_chain.
      for_conference(@conference).
      without_state(:cancelled).
      page(params[:page]).
      order('sessions.created_at DESC').
      includes(
        :author,
        :second_author,
        :session_type,
        :review_decision,
      )
  end

  def begin_of_association_chain
    action_name == 'new' ? current_user : nil
  end

end
