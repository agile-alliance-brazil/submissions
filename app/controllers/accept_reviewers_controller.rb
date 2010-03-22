class AcceptReviewersController < ApplicationController
  def show
    if @reviewer.preferences.empty?
      Track.all.each do |track|
        @reviewer.preferences.build(:track_id => track.id)
      end
    end
  end
  
  protected
  def authorize_action
    @reviewer = Reviewer.find(params[:reviewer_id])
    unauthorized! unless current_user == @reviewer.try(:user) && @reviewer.invited?
  end
end