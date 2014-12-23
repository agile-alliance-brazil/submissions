#encoding:utf-8
class VotesController < ApplicationController
  def index
    @sessions = current_user.voted_sessions.for_conference(@conference)
  end

  def create
    vote = Vote.new(vote_attributes)
    vote.save
    redirect_to request.referer
  end

  def destroy
    vote = resource
    vote.destroy

    redirect_to request.referer
  end

  private
  def resource
    Vote.find(params[:id])
  end

  def resource_class
    Vote
  end

  def vote_attributes
    attributes = params.require(:vote).permit(:session_id)
    attributes.merge(inferred_attributes)
  end

  def inferred_attributes
    {
      conference_id: @conference.id,
      user_id: current_user.id
    }
  end
end
