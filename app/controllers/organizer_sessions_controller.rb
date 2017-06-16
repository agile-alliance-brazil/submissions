# encoding: UTF-8
# frozen_string_literal: true

class OrganizerSessionsController < ApplicationController
  def index
    @session_filter = SessionFilter.new(filter_params)
    @states = Session.state_machine.states.map(&:name)

    @tracks = current_user.organized_tracks(@conference)
    prefilter_scope = Session.for_conference(@conference)
                             .for_tracks(@tracks.map(&:id)).page(params[:page]).order(order_from_params)
                             .includes(:author, :second_author, :track, :final_reviews, :review_decision, :track, :audience_level, :session_type)

    @sessions = @session_filter.apply(prefilter_scope)
    respond_to do |format|
      format.html
      format.json do
        render json: @sessions, include: {
          authors: { only: %i[id first_name last_name] },
          final_reviews: { only: %i[recommendation_id justification comments_to_organizers comments_to_authors reviewer_confidence_rating_id] },
          review_decision: { only: %i[id outcome_id note_to_authors] },
          track: { only: %i[id title] },
          audience_level: { only: %i[id title] },
          session_type: { only: %i[id title] }
        }
      end
    end
  end

  protected

  def order_from_params
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    "sessions.#{column} #{direction}"
  end

  def filter_params
    params.permit(session_filter: %i[track_id state])[:session_filter]
  end
end
