class ReviewerSessionsController < ApplicationController
  def index
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'sessions.created_at DESC'
    @sessions = Session.for_reviewer(current_user, current_conference).paginate(paginate_options)
  end  
end