class RegisteredAttendeesController < InheritedResources::Base
  defaults :resource_class => Attendee, :collection_name => "attendees", :instance_name => "attendee"
  actions :index, :show, :update
  
  def update
    if params[:attendee]
      attendee = Attendee.find(params[:id])
      params[:attendee][:status_event] = 'confirm' unless attendee.confirmed?
    end
    update! do |success, failure|
      success.html do
        if params[:attendee][:status_event] == 'confirm'
          flash[:notice] = t('flash.registered_attendees.confirm.success') 
        else
          flash[:notice] = t('flash.registered_attendees.update.success') 
        end
        redirect_to registered_attendees_path
      end
      failure.html do
        flash.now[:error] = "#{t('flash.failure')} #{@attendee.errors}"
        render :show
      end
    end
  end  
  
  private
  def collection
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'registration_date')
    order = "#{column} #{direction}"
    
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 30)
    paginate_options[:order] ||= order
    
    scope = end_of_association_chain.for_conference(current_conference).with_full_name
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.with_status(params[:status].to_sym) if params[:status].present?
    scope = scope.with_notes() if params[:notes].present?
    
    @attendees ||= scope.paginate(paginate_options)
  end
  
end