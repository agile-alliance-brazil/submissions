# encoding: UTF-8
class PendingAttendeesController < InheritedResources::Base
  defaults :resource_class => Attendee, :collection_name => "attendees", :instance_name => "attendee"
  actions :index, :update
  
  def update
    params[:attendee] = case params[:status]
      when 'update' then {:registration_date => Time.zone.now}
      when 'paid' then {:status_event => 'pay'}
    end
    update! do |success, failure|
      success.html { flash[:notice] = t('flash.pending_attendees.confirm.success') }
      failure.html { flash[:error]  = t('flash.failure') }
      redirect_to pending_attendees_path
    end
  end  
  
  private
  def current_registration_period
    RegistrationPeriod.for(Time.zone.now).first
  end
  
  def collection
    @attendees ||= end_of_association_chain.
      for_conference(current_conference).
      with_status(:pending).
      registered_before(current_registration_period.start_at).
      with_full_name
  end
  
end
