class UserSessionsController < InheritedResources::Base
  before_filter :login_required, :only => :destroy

  actions :new, :create
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.user_session.create.success')
        redirect_to_target_or_default(root_url)
      end
      failure.html do        
        flash[:error] = @user_session.errors.on(:base) unless @user_session.errors.on(:base).blank?
        render :new
      end
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = t('flash.user_session.destroy.success')
    redirect_to root_url
  end
end
