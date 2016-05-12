# encoding: UTF-8
class AcceptReviewersController < ApplicationController
  before_filter :load_reviewer, :load_audience_levels

  def show
    if @reviewer.preferences.empty?
      @conference.tracks.each do |track|
        @reviewer.preferences.build(track_id: track.id)
      end
    end
  end

  def update
    if accept_params && @reviewer.update_attributes(accept_params)
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

  def accept_params
    unless params[:reviewer].blank?
      params.require(:reviewer).
        permit(:reviewer_agreement, :sign_reviews,
          { preferences_attributes:
            [:accepted, :audience_level_id, :track_id] }).tap do |attr|
          attr[:state_event] = 'accept'
          attr[:preferences_attributes].each do |index, preferences|
            preferences[:reviewer_id] = @reviewer.id
          end
        end
    end
  end
end
