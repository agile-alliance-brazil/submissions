# encoding: UTF-8
# frozen_string_literal: true

class SessionTypesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  respond_to :json, :html

  def index
    @session_types = resource_class.for_conference(@conference).includes(:translated_contents)
  end

  def create
    @session_type = resource_class.new(session_type_params)
    respond_with @session_type do |format|
      format.html do
        handle_html_response(t('flash.session_type.create.success')) { @session_type.save }
      end
      format.json { handle_json_response { @session_type.save } }
    end
  end

  def update
    @session_type = resource_class.where(id: params[:id]).first
    respond_with @session_type do |format|
      format.html do
        handle_html_response(t('flash.session_type.update.success')) { @session_type.update_attributes(session_type_params) }
      end
      format.json { handle_json_response { @session_type.update_attributes(session_type_params) } }
    end
  end

  private

  def resource_class
    SessionType
  end

  def session_type_params
    allowed_params = []
    if @session_type.nil? || !@conference.visible?
      allowed_params << :needs_audience_limit
      allowed_params << :needs_mechanics
      allowed_params << { valid_durations: [] }
    end
    allowed_params << { translated_contents_attributes: %i[id language title content] }
    attrs = params.require(:session_type).permit(allowed_params)
    attrs = attrs.merge(conference_id: @conference.id)
    if attrs[:valid_durations]
      attrs[:valid_durations] = attrs[:valid_durations].map(&:to_i)
    end
    attrs
  end

  def handle_html_response(notice)
    result = yield
    if result
      redirect_to conference_session_types_path(@conference), notice: notice
    else
      render_conference_page_for_error
    end
  end

  def render_conference_page_for_error
    @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
    @new_track = Track.new(conference: @conference)
    @new_session_type = @session_type
    @new_audience_level = AudienceLevel.new(conference: @conference)
    @new_page = Page.new(conference: @conference)
    @conference.supported_languages.each do |code|
      @new_track.translated_contents.build(language: code)
      @new_audience_level.translated_contents.build(language: code)
      @new_page.translated_contents.build(language: code)
    end

    missing_langs = @conference.supported_languages - @session_type.translated_contents.map(&:language)
    missing_langs.each do |code|
      @session_type.translated_contents.build(language: code)
    end
    flash.now[:error] = 'Something went wrong'
    render template: 'conferences/edit'
  end

  def handle_json_response
    result = yield
    json_level = {
      valid_durations: @session_type.valid_durations,
      needs_audience_limit: @session_type.needs_audience_limit?,
      needs_mechanics: @session_type.needs_mechanics?,
      translations: @conference.languages.map do |l|
        c = @session_type.translated_contents.where(language: l[:code]).first
        { id: c.id, title: c.title, description: c.content, language: l }
      end
    }
    if result
      render json: json_level.merge(id: @session_type.id)
    else
      render json: json_level.merge(errors: @session_type.errors)
    end
  end
end
