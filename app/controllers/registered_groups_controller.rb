class RegisteredGroupsController < InheritedResources::Base
  defaults :resource_class => RegistrationGroup, :collection_name => "registration_groups", :instance_name => "registration_group"
  actions :index, :show, :update
  
  def update
    params[:registration_group][:status_event] = 'confirm' if params[:registration_group]
    update! do |success, failure|
      success.html do
        begin
          flash[:notice] = t('flash.registered_groups.confirm.success')
          EmailNotifications.registration_group_confirmed(@registration_group).deliver
        rescue => ex
          notify_hoptoad(ex)
        end
        redirect_to registered_groups_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :show
      end
    end
  end  
  
  private
  def collection
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'id')
    order = "#{column} #{direction}"
    
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 30)
    paginate_options[:order] ||= order
    
    scope = end_of_association_chain.for_conference(current_conference)
    scope = scope.with_status(params[:status].to_sym) if params[:status].present?
    
    @registration_groups ||= scope.paginate(paginate_options)
  end
  
end