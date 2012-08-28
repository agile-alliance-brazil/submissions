# encoding: UTF-8
class AcceptedSessionsController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  append_view_path ActivitiesResolver.new

  def index
    @activities = Activity.for_conference(@conference)
    render :layout => false
  end
end
