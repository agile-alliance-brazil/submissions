# encoding: UTF-8
class RegistrationsController < Devise::RegistrationsController

  # POST /resource
  def create
	build_resource(sign_up_params)

    if resource.save
      EmailNotifications.welcome(@user).deliver
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_data_after_sign_in!
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
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    changing_password = needs_password?

    if (changing_password ? resource.update_with_password(resource_params) : resource.update_without_password(resource_params))
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, (changing_password ? :password_updated : flash_key)
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords resource
      params[:update_password] = changing_password
      render :edit
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

  private
  def needs_password?
    !!params[resource_name].has_key?(:password)
  end
end
