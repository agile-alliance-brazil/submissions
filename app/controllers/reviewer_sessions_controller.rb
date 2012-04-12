# encoding: UTF-8
class ReviewerSessionsController < ApplicationController
  def index
    @sessions = Session.for_reviewer(current_user, @conference).page(params[:page]).order('sessions.created_at DESC')
  end
end
