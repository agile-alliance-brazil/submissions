# frozen_string_literal: true

class UserSessionsController < Devise::SessionsController
  skip_before_action :authorize_action

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    @conference = Conference.current
    @page = @conference.default_page
    if @page
      render template: 'pages/show'
    else
      render template: "static_pages/#{@conference.year}_home"
    end
  end
end
