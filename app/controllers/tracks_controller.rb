# encoding: UTF-8
class TracksController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  
  actions :index

  private
  def collection
    @tracks ||= end_of_association_chain.for_conference(current_conference)
  end
end
