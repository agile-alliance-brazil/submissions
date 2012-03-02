# encoding: UTF-8
class SessionTypesController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  
  actions :index
  
  private
  def collection
    @session_types ||= end_of_association_chain.for_conference(@conference)
  end
end
