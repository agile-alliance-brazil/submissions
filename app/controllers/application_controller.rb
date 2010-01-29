class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_locale
  before_filter :set_timezone
  before_filter :authorize_action
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t('flash.unauthorised')
    redirect_to :back rescue redirect_to root_path
  end
  
  def default_url_options(options={})
    # Keep locale when navigating links if locale is specified
    params[:locale] ? { :locale => params[:locale] } : {}
  end
  
  private
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end 

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = params[:time_zone]
  end
  
  def authorize_action
    obj = resource rescue nil
    unauthorized! if cannot?(params[:action].to_sym, (obj || resource_class)) rescue nil
  end
end
