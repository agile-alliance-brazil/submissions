class UsersController < InheritedResources::Base
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
        UserSession.create(@user)
        flash[:notice] = t('flash.user.create.success')
        redirect_to root_url
      end
    end
  end
  
end
