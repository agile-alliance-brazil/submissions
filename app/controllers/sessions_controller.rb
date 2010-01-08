class SessionsController < InheritedResources::Base
  before_filter :login_required
  
  actions :index, :show, :new, :create
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.session.create.success')
        redirect_to session_path(@session)
      end
    end
  end
  
  protected
    
  def collection
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 20)
    @sessions ||= end_of_association_chain.paginate(paginate_options)
  end
  
  def begin_of_association_chain
    current_user
  end
        
end