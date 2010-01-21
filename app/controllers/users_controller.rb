class UsersController < InheritedResources::Base
  before_filter :logout_required, :only => [:new, :create]
  has_scope :search, :only => :index, :as => 'q'
  
  actions :index, :new, :create, :show
  respond_to :js, :only => :index
  respond_to :html, :except => :index
  
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
