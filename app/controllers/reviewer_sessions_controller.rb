# encoding: UTF-8
class ReviewerSessionsController < InheritedResources::Base
  defaults :resource_class => Session
  actions :index
  respond_to :html

  before_filter :load_session_filter
  before_filter :load_tracks
  before_filter :load_session_types
  before_filter :load_audience_levels

  has_scope :filtered, :only => :index, :as => :session_filter, :type => :hash do |controller, scope, value|
    controller.send(:load_session_filter).apply(scope)
  end

  protected
  def collection
    @sessions ||= begin
      scope = if @conference.in_early_review_phase?
        end_of_association_chain.for_reviewer(current_user, @conference).order('sessions.early_reviews_count ASC')
      elsif @conference.in_final_review_phase?
        end_of_association_chain.for_reviewer(current_user, @conference).order('sessions.final_reviews_count ASC')
      else
        end_of_association_chain.none
      end
      scope.page(params[:page])
    end
  end

  def load_tracks
    @tracks ||= @conference.tracks
  end

  def load_audience_levels
    @audience_levels ||= @conference.audience_levels
  end

  def load_session_types
    @session_types ||= @conference.session_types
  end

  def load_session_filter
    @session_filter ||= SessionFilter.new(params)
  end
end
