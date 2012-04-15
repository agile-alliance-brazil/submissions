# encoding: UTF-8
class ReviewerSessionsController < ApplicationController
  def index
    if @conference.in_early_review_phase?
      scope = Session.incomplete_early_reviews_for(@conference)
    else
      scope = Session.with_incomplete_final_reviews
    end
    @sessions = scope.for_reviewer(current_user, @conference).page(params[:page]).order('sessions.created_at DESC')
  end
end
