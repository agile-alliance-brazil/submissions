# encoding: UTF-8
class RegistrationGroupStatusesController < InheritedResources::Base
  defaults :resource_class => RegistrationGroup, :instance_name => "registration_group"
  skip_before_filter :authenticate_user!
  actions :show
  
  private
  def resource
    @registration_group ||= end_of_association_chain.find_by_uri_token!(params[:id])
  end
end
