# encoding: UTF-8
class OrganizerSessionsController < ApplicationController
  def index
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    order = "sessions.#{column} #{direction}"

    @sessions = Session.for_conference(@conference).
                        for_tracks(current_user.organized_tracks(@conference).map(&:id)).
                        page(params[:page]).
                        order(order)
  end
end
