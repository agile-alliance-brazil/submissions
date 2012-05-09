# encoding: UTF-8
class ReviewerSessionsController < ApplicationController
  def index
    if @conference.in_early_review_phase?
      scope = Session.for_reviewer(current_user, @conference).order('sessions.early_reviews_count ASC')
    elsif @conference.in_final_review_phase?
      scope = Session.for_reviewer(current_user, @conference).order('sessions.final_reviews_count ASC')
    else
      scope = Session.none
    end
    @sessions = scope.page(params[:page])
  end
end
