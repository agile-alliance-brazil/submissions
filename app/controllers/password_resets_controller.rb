# encoding: UTF-8
# frozen_string_literal: true

class PasswordResetsController < Devise::PasswordsController
  # PATCH /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash.now[:error] = resource.errors[:reset_password_token] unless resource.errors[:reset_password_token].empty?
      respond_with resource
    end
  end

  protected

  def after_sending_reset_password_instructions_path_for(_resource)
    root_path
  end
end
