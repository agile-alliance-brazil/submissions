# encoding: UTF-8
class TracksController < ApplicationController
  skip_before_filter :authenticate_user!, only: %i(index)

  def index
    @tracks = resource_class.for_conference(@conference).includes(:translated_contents).all
  end

  def create
    @track = resource_class.new(track_params)
    if @track.save
      flash[:notice] = t('flash.track.create.success')
      redirect_to conference_tracks_path(@conference)
    else
      @new_track = @track
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  def update
    @track = resource_class.where(id: params[:id]).first
    if @track.update_attributes(track_params)
      flash[:notice] = t('flash.track.update.success')
      redirect_to conference_tracks_path(@conference)
    else
      @new_track = @track
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  private
  def resource_class
    Track
  end

  def track_params
    attrs = params.require(:track).permit(translated_contents_attributes: [:id, :language, :title, :description])
    attrs.merge(conference_id: @conference.id)
  end
end
