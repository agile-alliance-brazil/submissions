class SessionsController < InheritedResources::Base
  before_filter :login_required
  
  actions :all, :except => [:destroy]
  has_scope :for_user, :only => :index, :as => 'user_id'
  before_filter :load_user
  has_scope :tagged_with, :only => :index
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.session.create.success')
        redirect_to session_path(@session)
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
        flash[:notice] = t('flash.session.update.success')
        redirect_to session_path(@session)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end  
  
  protected
  
  def load_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end
    
  def collection
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 15)
    paginate_options[:order] ||= 'sessions.created_at DESC'
    @sessions ||= end_of_association_chain.paginate(paginate_options)
  end
  
  def begin_of_association_chain
    action_name == 'new' ? current_user : nil
  end
        
end