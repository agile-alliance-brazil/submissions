class RegisteredAttendeesController < InheritedResources::Base
  defaults :resource_class => Attendee, :collection_name => "attendees", :instance_name => "attendee"
  actions :index, :show, :update

  def update
    params[:attendee][:status_event] = 'confirm' if params[:attendee]
    update! do |success, failure|
      success.html do
        begin
          flash[:notice] = t('flash.registered_attendees.confirm.success')
          EmailNotifications.registration_confirmed(@attendee).deliver
        rescue => ex
          notify_hoptoad(ex)
        end
        redirect_to registered_attendees_path
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
    column = sanitize(params[:column] || 'created_at')
    order = "attendees.#{column} #{direction}"
    
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 30)
    paginate_options[:order] ||= order
    
    @attendees ||= end_of_association_chain.for_conference(current_conference).paginate(paginate_options)
  end
  
end