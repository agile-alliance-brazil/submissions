# encoding: UTF-8
# frozen_string_literal: true

class TracksController < ApplicationController
  skip_before_action :authenticate_user!, only: %i(index)
  respond_to :json, :html

  def index
    @tracks = resource_class.for_conference(@conference).includes(:translated_contents).all
  end

  def create
    @track = resource_class.new(track_params)
    respond_with @track do |format|
      format.html do
        handle_html_response(t('flash.track.create.success')) { @track.save }
      end
      format.json { handle_json_response { @track.save } }
    end
  end

  def update
    @track = resource_class.where(id: params[:id]).first
    respond_with @track do |format|
      format.html do
        handle_html_response(t('flash.track.update.success')) { @track.update_attributes(track_params) }
      end
      format.json { handle_json_response { @track.update_attributes(track_params) } }
    end
  end

  private

  def resource_class
    Track
  end

  def track_params
    attrs = params.require(:track).permit(translated_contents_attributes: %i(id language title content))
    attrs.merge(conference_id: @conference.id)
  end

  def handle_html_response(notice)
    result = yield
    if result
      redirect_to conference_tracks_path(@conference), notice: notice
    else
      render_conference_page_for_error
    end
  end

  def render_conference_page_for_error
    @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
    @new_track = @track
    @new_session_type = SessionType.new(conference: @conference)
    @new_audience_level = AudienceLevel.new(conference: @conference)
    @new_page = Page.new(conference: @conference)
    @conference.supported_languages.each do |code|
      @new_session_type.translated_contents.build(language: code)
      @new_audience_level.translated_contents.build(language: code)
      @new_page.translated_contents.build(language: code)
    end

    missing_langs = @conference.supported_languages - @new_track.translated_contents.map(&:language)
    missing_langs.each do |code|
      @new_track.translated_contents.build(language: code)
    end
    flash.now[:error] = 'Something went wrong'
    render template: 'conferences/edit'
  end

  def handle_json_response
    result = yield
    json_track = {
      translations: @conference.languages.map do |l|
        c = @track.translated_contents.where(language: l[:code]).first
        { id: c.id, title: c.title, description: c.content, language: l }
      end
    }
    if result
      render json: json_track.merge(id: @track.id)
    else
      render json: json_track.merge(errors: @track.errors)
    end
  end
end
