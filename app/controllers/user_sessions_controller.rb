# encoding: UTF-8
class UserSessionsController < Devise::SessionsController
  skip_before_filter :authorize_action

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    @conference = Conference.current
    page = @conference.pages.with_path('/').first
    if page
      render template: "conferences/show"
    else
      render template: "static_pages/#{@conference.year}_home"
    end
  end
end
