class AcceptedSessionsController < InheritedResources::Base
  def index
    @sessions = Session.with_state(:accepted)
    @tracks = Track.all
  end
end