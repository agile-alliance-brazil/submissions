# encoding: UTF-8
class RegistrationsController < Devise::RegistrationsController

  # POST /resource
  def create
    build_resource

    if resource.save
      EmailNotifications.send_welcome(@user)
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords resource
      respond_with resource
    end
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected
  def build_resource(hash = nil)
    super.tap do |u|
      u.default_locale = I18n.locale
    end
  end

  def after_update_path_for(resource)
    user_path(resource)
  end
end
