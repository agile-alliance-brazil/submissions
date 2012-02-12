# encoding: UTF-8
class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource

    if resource.save
      EmailNotifications.welcome(@user).deliver
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end

  def update
    if resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to user_path(resource)
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end

  protected
  def build_resource(hash = nil)
    super.tap do |u|
      u.default_locale = I18n.locale
    end
  end
end
