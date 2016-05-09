# encoding: UTF-8
class AudienceLevelsController < ApplicationController
  skip_before_filter :authenticate_user!, only: %i(index)
  respond_to :json, :html

  def index
    @audience_levels = resource_class.for_conference(@conference).includes(:translated_contents)
  end

  def create
    @audience_level = resource_class.new(audience_level_params)
    if @audience_level.save
      send_success_response(t('flash.audience_level.create.success'))
    else
      @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
      @new_track = Track.new(conference: @conference)
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = @audience_level
      @new_page = Page.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_page.translated_contents.build(language: code)
      end

      missing_langs = @conference.supported_languages - @new_audience_level.translated_contents.map(&:language)
      missing_langs.each do |code|
        @new_audience_level.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  def update
    @audience_level = resource_class.where(id: params[:id]).first
    if @audience_level.update_attributes(audience_level_params)
      send_success_response(t('flash.audience_level.update.success'))
    else
      @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
      @new_track = Track.new(conference: @conference)
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = @audience_level
      @new_page = Page.new(conference: @conference)
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_page.translated_contents.build(language: code)
      end

      missing_langs = @conference.supported_languages - @new_audience_level.translated_contents.map(&:language)
      missing_langs.each do |code|
        @new_audience_level.translated_contents.build(language: code)
      end
      flash.now[:error] = 'Something went wrong'
      render template: 'conferences/edit'
    end
  end

  protected
  def resource_class
    AudienceLevel
  end

  def audience_level_params
    attrs = params.require(:audience_level).permit(translated_contents_attributes: %i(id language title content))
    attrs.merge(conference_id: @conference.id)
  end

  def send_success_response(notice)
    respond_with @audience_level do |format|
       format.html {
         redirect_to conference_audience_levels_path(@conference), notice: notice
       }
       format.json {
         render json: {
           id: @audience_level.id,
           translations: @conference.languages.map do |l|
             I18n.with_locale(l[:code]) do
               {title: @audience_level.title, description: @audience_level.description, language: l }
             end
           end
         }
       }
     end
  end
end
