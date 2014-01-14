# encoding: UTF-8
class AcceptedSessionsController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  append_view_path ActivitiesResolver.new

  respond_to :json, :html

  def index
    @activities = Activity.for_conference(@conference)
    respond_with(@activities) do |format|
      format.html {render :layout => false}
      format.json {render :json => @activities.to_json}
    end
  end
end
