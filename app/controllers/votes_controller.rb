class VotesController < ApplicationController

  def create
    @vote = Vote.new "session_id" => params[:session_id], "user_id" => current_user.id, "year" => params[:year]
    if @vote.save
      redirect_to sessions_path(params[:vote][:year])
    end
  end

  def destroy

  end
end
