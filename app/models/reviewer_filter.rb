# encoding: UTF-8
# frozen_string_literal: true
class ReviewerFilter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :state, :track_id

  def initialize(params = {})
    return unless params[:reviewer_filter]

    @state = params[:reviewer_filter][:state]
    @track_id = params[:reviewer_filter][:track_id]
  end

  def apply(scope)
    scope = scope.with_state(@state.to_sym) if @state.present?
    scope = scope.for_track(@track_id) if @track_id.present?
    scope
  end

  def persisted?
    false
  end
end
