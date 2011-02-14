class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery

  before_filter :set_locale
  before_filter :set_timezone
  before_filter :login_required
  before_filter :authorize_action

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"

    flash[:error] = t('flash.unauthorised')
    redirect_to :back rescue redirect_to root_path
  end

  def current_conference
    @current_conference ||= Conference.current
  end
  helper_method :current_conference

  def current_ability
    @current_ability ||= Ability.new(current_user, current_conference, params)
  end

  def default_url_options(options={})
    # Keep locale when navigating links if locale is specified
    params[:locale] ? { :locale => params[:locale] } : {}
  end

  def sanitize(text)
    text.gsub(/[\s;'\"]/,'')
  end

  protected
  def render_optional_error_file(status_code)
    set_locale
    status = interpret_status(status_code)
    template = self.view_paths.find_template("errors/#{status[0,3]}", :html)

    render :template => template, :status => status, :content_type => Mime::HTML
  rescue
    super
  end

  private
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale] || current_user.try(:default_locale)
  end

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = params[:time_zone]
  end

  def authorize_action
    obj = resource rescue nil
    clazz = resource_class rescue nil
    action = params[:action].to_sym
    controller = obj || clazz || controller_name
    authorize!(action, controller)
  end
end
