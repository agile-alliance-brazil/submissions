# frozen_string_literal: true

class AudienceLevelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  respond_to :json, :html

  def index
    @audience_levels = resource_class.for_conference(@conference).includes(:translated_contents)
  end

  def create
    @audience_level = resource_class.new(audience_level_params)
    respond_with @audience_level do |format|
      format.html do
        handle_html_response(t('flash.audience_level.create.success')) { @audience_level.save }
      end
      format.json { handle_json_response { @audience_level.save } }
    end
  end

  def update
    @audience_level = resource_class.where(id: params[:id]).first
    respond_with @audience_level do |format|
      format.html do
        handle_html_response(t('flash.audience_level.update.success')) { @audience_level.update_attributes(audience_level_params) }
      end
      format.json { handle_json_response { @audience_level.update_attributes(audience_level_params) } }
    end
  end

  protected

  def resource_class
    AudienceLevel
  end

  def audience_level_params
    attrs = params.require(:audience_level).permit(translated_contents_attributes: %i[id language title content])
    attrs.merge(conference_id: @conference.id)
  end

  def handle_html_response(notice)
    result = yield
    if result
      redirect_to conference_audience_levels_path(@conference), notice: notice
    else
      render_conference_page_for_error
    end
  end

  def render_conference_page_for_error
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

  def handle_json_response
    result = yield
    json_level = {
      translations: @conference.languages.map do |l|
        c = @audience_level.translated_contents.where(language: l[:code]).first
        { id: c.id, title: c.title, description: c.content, language: l }
      end
    }
    if result
      render json: json_level.merge(id: @audience_level.id)
    else
      render json: json_level.merge(errors: @audience_level.errors)
    end
  end
end
