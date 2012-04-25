# encoding: UTF-8
class ReviewerSessionsController < ApplicationController
  def index
  	scope = Session.all
    if @conference.in_early_review_phase?
      scope = Session.early_reviewable_by(current_user, @conference).order('sessions.early_reviews_count ASC')
    else
      scope = Session.for_reviewer(current_user, @conference).with_incomplete_final_reviews.order('sessions.created_at DESC')
    end
    @sessions = scope.page(params[:page])
  end
end
