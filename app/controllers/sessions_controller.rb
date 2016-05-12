# encoding: UTF-8
class SessionsController < ApplicationController
  before_filter :load_user
  before_filter :load_tracks
  before_filter :load_audience_levels
  before_filter :load_session_types
  before_filter :load_tags, except: :show

  def index
    @session_filter = SessionFilter.new(filter_params, params[:user_id])
    @sessions ||= @session_filter.apply(Session).
      for_conference(@conference).
      without_state(:cancelled).
      page(params[:page]).
      order('sessions.created_at DESC').
      includes(:author, :second_author, :review_decision,
        session_type: [:translated_contents],
        track: [:translated_contents],
        audience_level: [:translated_contents])
    @session_types = @conference.session_types.includes(:translated_contents).order(created_at: :asc)
  end

  def new
    @session = Session.new(conference_id: @conference.id, author_id: current_user.id)
  end

  def create
    @session = Session.new(session_params)
    if @session.save
      EmailNotifications.session_submitted(@session).deliver_now
      flash[:notice] = t('flash.session.create.success')
      redirect_to session_path(@conference, @session)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def show
    @session = resource
    @comment = Comment.new(user_id: current_user.id, commentable_id: @session.id)
    if @session.conference != @conference
      flash.now[:news] = t('flash.news.session_different_conference',
        conference_name: @session.conference.name,
        current_conference_name: @conference.name).html_safe
    end
  end

  def edit
    @session = resource
  end

  def update
    @session = resource
    if @session.update_attributes(session_params)
      flash[:notice] = t('flash.session.update.success')
      redirect_to session_path(@conference, @session)
    else
      flash.now[:error] = t('flash.failure')
      render :edit
    end
  end

  def cancel
    flash[:error] = t('flash.session.cancel.failure') unless resource.cancel
    redirect_to organizer_sessions_path(@conference)
  end

  protected
  def session_params
    valid_params = params.require(:session).permit([
      :title, :summary, :description, :mechanics, :benefits,
      :target_audience, :prerequisites, :audience_level_id, :audience_limit,
      :second_author_username, :track_id,
      :session_type_id, :duration_mins, :experience,
      :keyword_list, :language
    ]).merge(conference_id: @conference.id)
    if valid_params[:keyword_list]
      valid_params[:keyword_list] = valid_params[:keyword_list].split(',').reject {|name| @tags.detect {|tag| tag.name == name}.nil?}
    end
    valid_params[:author_id] = current_user.id unless @session
    valid_params
  end

  def resource
    Session.includes(
      session_type: [:translated_contents],
      track: [:translated_contents],
      audience_level: [:translated_contents]
).find(params[:id])
  end

  def resource_class
    Session
  end

  def load_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def load_tracks
    @tracks ||= @conference.tracks.includes(:translated_contents).order(title: :asc)
  end

  def load_audience_levels
    @audience_levels ||= @conference.audience_levels.includes(:translated_contents)
  end

  def load_session_types
    @session_types ||= @conference.session_types.includes(:translated_contents)
  end

  def filter_params
    params.permit(session_filter: [:tags, :username, :track_id, :session_type_id])[:session_filter]
  end

  def load_tags
    if @conference.tags.empty?
      @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
    else
      @tags = @conference.tags.to_a
    end
  end
end
