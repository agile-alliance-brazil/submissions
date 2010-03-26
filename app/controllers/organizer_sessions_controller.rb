class OrganizerSessionsController < ApplicationController
  def index
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanatize(params[:column] || 'created_at') 
    order = "sessions.#{column} #{direction}"
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= order
    @sessions = Session.for_tracks(current_user.organized_tracks.map(&:id)).paginate(paginate_options)
  end  
  
  private
  def sanatize(text)
    text.gsub(/[\s;'\"]/,'')
  end
end