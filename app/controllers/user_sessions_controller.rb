# encoding: UTF-8
class UserSessionsController < Devise::SessionsController
  skip_before_filter :authorize_action

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    render template: "static_pages/#{Conference.current.year}_home"
  end
end
