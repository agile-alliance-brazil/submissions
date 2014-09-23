# encoding: UTF-8
class OrganizerSessionsController < InheritedResources::Base
  defaults resource_class: Session
  actions :index
  respond_to :html

  before_filter :load_tracks
  before_filter :load_states
  before_filter :load_session_filter

  has_scope :filtered, only: :index, as: :session_filter, type: :hash do |controller, scope, value|
    controller.send(:load_session_filter).apply(scope)
  end

  protected
  def collection
    direction = params[:direction] == 'up' ? 'ASC' : 'DESC'
    column = sanitize(params[:column].presence || 'created_at')
    order = "sessions.#{column} #{direction}"

    @sessions = end_of_association_chain.
                  for_conference(@conference).
                  for_tracks(load_tracks.map(&:id)).
                  page(params[:page]).
                  order(order).
                  includes(:author, :second_author, :track)
  end

  def load_tracks
    @tracks ||= current_user.organized_tracks(@conference)
  end

  def load_states
    @states ||= Session.state_machine.states.map(&:name)
  end

  def load_session_filter
    @session_filter ||= SessionFilter.new(params)
  end
end
