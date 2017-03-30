# encoding: UTF-8
# frozen_string_literal: true

class OrganizerSessionsController < ApplicationController
  def index
    @session_filter = SessionFilter.new(filter_params)
    @states = Session.state_machine.states.map(&:name)

    @tracks = current_user.organized_tracks(@conference)
    prefilter_scope = Session.for_conference(@conference)
                             .for_tracks(@tracks.map(&:id)).page(params[:page]).order(order_from_params)
                             .includes(:author, :second_author, :track)

    @sessions = @session_filter.apply(prefilter_scope)
  end

  protected

  def order_from_params
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    "sessions.#{column} #{direction}"
  end

  def filter_params
    params.permit(session_filter: %i(track_id state))[:session_filter]
  end
end
