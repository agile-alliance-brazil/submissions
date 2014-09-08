# encoding: UTF-8
class AcceptReviewersController < ApplicationController
  before_filter :load_reviewer, :load_audience_levels
  
  def show
    if @reviewer.preferences.empty?
      @conference.tracks.each do |track|
        @reviewer.preferences.build(:track_id => track.id)
      end
    end
  end

  def update
    if @reviewer.update_attributes(params[:reviewer].try(:merge, {:state_event => 'accept'}))
      flash[:notice] = t('flash.reviewer.accept.success')
      redirect_to reviewer_sessions_path(@conference)
    else
      flash.now[:error] = t('flash.failure')
      render :show
    end
  end  
  
  private
  def load_audience_levels
    @audience_levels ||= @conference.audience_levels
  end

  def load_reviewer
    @reviewer = Reviewer.find(params[:reviewer_id])
  end
end
