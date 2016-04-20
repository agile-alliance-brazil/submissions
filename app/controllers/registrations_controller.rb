# encoding: UTF-8
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
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, (needs_password? ? :password_updated : flash_key)
      end
      sign_in resource_name, resource, bypass: true
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
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :username,
        :email, :password, :password_confirmation,
        :phone, :country, :state, :city, :organization,
        :website_url, :bio, :wants_to_submit,
        :default_locale, :twitter_username)
    end
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:first_name, :last_name, :username,
        :email, :current_password, :password, :password_confirmation,
        :phone, :country, :state, :city, :organization,
        :website_url, :bio, :wants_to_submit,
        :default_locale, :twitter_username)
    end
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def update_resource(resource, params)
    needs_password? ?
      resource.update_with_password(params) :
      resource.update_without_password(params)
  end

  private
  def needs_password?
    !!account_update_params.has_key?(:password)
  end
end
