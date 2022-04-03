# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      EmailNotifications.welcome(@user).deliver_now
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords resource
      respond_with resource
    end
  end

  # PATCH /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = if update_needs_confirmation?(resource, prev_unconfirmed_email)
                      :update_needs_confirmation
                    else
                      :updated
                    end
        set_flash_message :notice, (needs_password? ? :password_updated : flash_key)
      end
      bypass_sign_in resource
      respond_with resource, location: after_update_path_for(resource)
    else
      flash.now[:error] = t('flash.failure')
      clean_up_passwords resource
      params[:update_password] = needs_password?
      render :edit
    end
  end

  protected

  def build_resource(hash = nil)
    super.tap do |u|
      u.default_locale = I18n.locale
    end
  end

  def configure_permitted_parameters
    permitted_attrs = %i[first_name last_name username
                         email password password_confirmation
                         phone country state city organization
                         website_url bio wants_to_submit
                         default_locale twitter_username
                         gender race].freeze
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(*permitted_attrs) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(*permitted_attrs, :current_password) }
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def update_resource(resource, params)
    if needs_password?
      resource.update_with_password(params)
    else
      resource.update_without_password(params)
    end
  end

  private

  def needs_password?
    account_update_params.key?(:password)
  end
end
