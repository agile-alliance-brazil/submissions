# encoding: UTF-8
class AcceptReviewersController < ApplicationController
  def show
    @reviewer = Reviewer.find(params[:reviewer_id])
    if @reviewer.preferences.empty?
      @conference.tracks.each do |track|
        @reviewer.preferences.build(:track_id => track.id)
      end
    end
  end
end
