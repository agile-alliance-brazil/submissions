# encoding: UTF-8
class SessionTypesController < ApplicationController
  skip_before_filter :authenticate_user!, only: %i(index)

  def index
    @session_types = resource_class.for_conference(@conference).includes(:translated_contents)
  end

  def create
    @session_type = resource_class.new(session_type_params)
    if @session_type.save
      flash[:notice] = t('flash.session_type.create.success')
      redirect_to conference_session_types_path(@conference)
    else
      @new_track = Track.new(conference: @conference)
      @new_session_type = @session_type
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @new_page = Page.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
        @new_page.translated_contents.build(language: code)
      end

      missing_langs = @conference.supported_languages - @new_session_type.translated_contents.map(&:language)
      missing_langs.each do |code|
        @new_session_type.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  def update
    @session_type = resource_class.where(id: params[:id]).first
    if @session_type.update_attributes(session_type_params)
      flash[:notice] = t('flash.session_type.update.success')
      redirect_to conference_session_types_path(@conference)
    else
      @new_track = Track.new(conference: @conference)
      @new_session_type = @session_type
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @new_page = Page.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
        @new_page.translated_contents.build(language: code)
      end

      missing_langs = @conference.supported_languages - @new_session_type.translated_contents.map(&:language)
      missing_langs.each do |code|
        @new_session_type.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  private
  def resource_class
    SessionType
  end

  def session_type_params
    attrs = params.require(:session_type).permit(translated_contents_attributes: %i(id language title content))
    attrs.merge(conference_id: @conference.id)
  end
end
