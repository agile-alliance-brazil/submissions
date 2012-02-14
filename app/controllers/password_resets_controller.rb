# encoding: UTF-8
class PasswordResetsController < Devise::PasswordsController

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      flash.now[:error] = resource.errors[:reset_password_token] unless resource.errors[:reset_password_token].empty?
      respond_with resource
    end
  end

  protected
  def after_sending_reset_password_instructions_path_for(resource)
    root_path
  end
end
