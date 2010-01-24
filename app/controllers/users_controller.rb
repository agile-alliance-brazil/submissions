class UsersController < InheritedResources::Base
  before_filter :logout_required, :only => [:new, :create]
  has_scope :search, :only => :index, :as => 'q'
  
  actions :index, :new, :create, :show
  
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
