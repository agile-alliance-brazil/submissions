class OrganizerSessionsController < ApplicationController
  def index
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'sessions.created_at DESC'
    @sessions = Session.for_tracks(current_user.organized_tracks.map(&:id)).paginate(paginate_options)
  end  
end