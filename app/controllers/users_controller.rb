class UsersController < InheritedResources::Base
  skip_before_filter :login_required
  before_filter :logout_required, :only => [:new, :create]
  before_filter :login_required, :only => [:edit, :update]
  has_scope :search, :only => :index, :as => 'q'
  
  actions :all, :except => [:destroy]
  
  def index
    index! do |format|
      format.html { redirect_to new_user_path }
      format.js
    end
  end
  
  def create
    create! do |success, failure|
      success.html do
        EmailNotifications.deliver_welcome(@user)
        UserSession.create(@user)
        flash[:notice] = t('flash.user.create.success')
        redirect_to root_url
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = t('flash.user.update.success')
        redirect_to user_path(@user)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end  
end
