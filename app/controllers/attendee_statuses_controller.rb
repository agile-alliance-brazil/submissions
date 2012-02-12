# encoding: UTF-8
class AttendeeStatusesController < InheritedResources::Base
  defaults :resource_class => Attendee, :instance_name => "attendee"
  skip_before_filter :authenticate_user!
  actions :show
  
  private
  def resource
    @attendee ||= end_of_association_chain.find_by_uri_token!(params[:id])
  end
end
