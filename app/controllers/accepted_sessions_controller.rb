# encoding: UTF-8
class AcceptedSessionsController < InheritedResources::Base
  skip_before_filter :authenticate_user!

  def index
    @sessions = Session.for_conference(@conference).with_state(:accepted)
    @sessions_by_track = @sessions.group_by(&:track)
    render :layout => false
  end
end
