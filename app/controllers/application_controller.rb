# encoding: UTF-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :sessions_by_track
  helper_method :sessions_by_type
  protect_from_forgery

  around_filter :set_locale
  around_filter :set_timezone
  before_filter :set_conference
  before_filter :authenticate_user!
  before_filter :authorize_action

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"

    flash[:error] = t('flash.unauthorised')
    redirect_to :back rescue redirect_to root_path
  end

  def current_ability
    session = Session.find(params[:session_id]) if params[:session_id].present?
    reviewer = Reviewer.find(params[:reviewer_id]) if params[:reviewer_id].present?
    @current_ability ||= Ability.new(current_user, @conference, session, reviewer)
  end

  def default_url_options(options={})
    # Keep locale when navigating links if locale is specified
    params[:locale] ? { :locale => params[:locale] } : {}
  end

  def sanitize(text)
    text.gsub(/[\s;'\"]/,'')
  end

  def sessions_by_track
    session_track_count = ""
    @conference.tracks.all.each do |t|
      session_track_count << ", ['#{t(t.title)}', #{t.sessions.count}]"
    end
    session_track_count
  end

  def sessions_by_type
    session_type_count = ""
    SessionType.where(conference_id: @conference).each do |type|
      sessions_in_this_type = Session.where(session_type_id: type).count
      session_type_count << ", ['#{t(type.title)}', #{sessions_in_this_type}]"
    end
    session_type_count
  end

  private
  def set_locale(&block)
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.with_locale(params[:locale] || current_user.try(:default_locale), &block)
  end

  def set_timezone(&block)
    Time.use_zone(params[:time_zone], &block)
  end

  def set_conference
    @conference ||= Conference.find_by_year(params[:year]) || Conference.current
  end

  def authorize_action
    obj = resource rescue nil
    clazz = resource_class rescue nil
    action = params[:action].to_sym
    controller = obj || clazz || controller_name
    authorize!(action, controller)
  end
end
