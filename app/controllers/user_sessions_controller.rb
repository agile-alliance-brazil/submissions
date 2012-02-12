# encoding: UTF-8
class UserSessionsController < Devise::SessionsController
  skip_before_filter :authorize_action
  
  def new
    build_resource
    render :template => 'static_pages/home'
  end
end
