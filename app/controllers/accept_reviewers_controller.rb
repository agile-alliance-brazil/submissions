# encoding: UTF-8
class AcceptReviewersController < ApplicationController
  before_filter :load_audience_levels
  
  def show
    @reviewer = Reviewer.find(params[:reviewer_id])
    if @reviewer.preferences.empty?
      @conference.tracks.each do |track|
        @reviewer.preferences.build(:track_id => track.id)
      end
    end
  end
  
  private
  def load_audience_levels
    @audience_levels ||= Conference.current.audience_levels
  end
end
