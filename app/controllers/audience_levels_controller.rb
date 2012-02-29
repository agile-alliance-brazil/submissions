# encoding: UTF-8
class AudienceLevelsController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  
  actions :index

  private
  def collection
    @audience_levels ||= end_of_association_chain.for_conference(@conference)
  end
end
