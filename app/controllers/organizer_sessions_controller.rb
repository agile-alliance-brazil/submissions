class OrganizerSessionsController < ApplicationController
  def index
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanatize(params[:column] || 'created_at')

    if(column != 'reviews')
      order = "sessions.#{column} #{direction}"
    end

    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= order
    @sessions = Session.for_tracks(current_user.organized_tracks.map(&:id)).paginate(paginate_options)
    
    @sessions = sort_by_review_count(@sessions, direction == 'DESC') if(column == 'reviews')
  end  
  
  private
  def sort_by_review_count(sessions, reverse)
    sessions.sort do |s1, s2|
      sort = (s1.reviews.count <=> s2.reviews.count)
      if reverse
        sort * -1
      else
        sort
      end
    end
  end
end