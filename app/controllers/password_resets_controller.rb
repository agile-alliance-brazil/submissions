# encoding: UTF-8
class PasswordResetsController < Devise::PasswordsController

  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to root_path
    else
      render_with_scope :new
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :updated
      sign_in_and_redirect(resource_name, resource)
    else
      flash.now[:error] = resource.errors[:reset_password_token] unless resource.errors[:reset_password_token].empty?
      render_with_scope :edit
    end
  end

end
