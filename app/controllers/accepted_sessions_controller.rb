# encoding: UTF-8
class AcceptedSessionsController < InheritedResources::Base
  def index
    @sessions = Session.for_conference(current_conference).with_state(:accepted)
    @tracks = Track.all
  end
end
