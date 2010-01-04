class UsersController < InheritedResources::Base
  before_filter :logout_required, :only => [:new, :create]
  
  actions :new, :create
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.user.create.success')
        redirect_to root_url
      end
    end
  end
end
