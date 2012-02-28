# encoding: UTF-8
class AcceptedSessionsController < InheritedResources::Base
  def index
    @sessions = Session.for_conference(@conference).with_state(:accepted)
    @tracks = @conference.tracks
  end
end
