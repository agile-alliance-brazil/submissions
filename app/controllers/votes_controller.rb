class VotesController < ApplicationController
  def index
    @sessions = current_user.voted_sessions
  end

  def create
    @vote = Vote.new params[:vote]
    can_vote = @vote.try(:session).can_be_voted_by?(current_user)
    if can_vote && @vote.save
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js { head :ok }
      end
    else
      respond_to do |format|
        format.js { head :internal_server_error }
      end
    end
  end

  def destroy
    @vote = Vote.find params[:id]
    year = @vote.year
    if @vote.destroy
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js { head :ok }
      end
    else
      respond_to do |format|
        format.js { head :internal_server_error }
      end
    end
  end
end
