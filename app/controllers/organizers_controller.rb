class OrganizersController < InheritedResources::Base
  actions :index, :new, :create, :update, :edit, :destroy
  respond_to :html
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.organizer.create.success')
        redirect_to organizers_path
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
        flash[:notice] = t('flash.organizer.update.success')
        redirect_to organizers_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end  
  
  protected
  def collection
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'organizers.created_at DESC'
    @organizers ||= end_of_association_chain.paginate(paginate_options)
  end
end