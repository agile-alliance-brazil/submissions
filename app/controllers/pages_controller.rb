# encoding: UTF-8
# frozen_string_literal: true
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  respond_to :json, :html

  def show
    @page = resource
    if @page
      render :show
    else
      begin
        render template: "static_pages/#{@conference.year}_#{path}"
      rescue ActionView::MissingTemplate
        render file: Rails.root.join('public', '404.html'), layout: false, status: 404
      end
    end
  end

  def create
    @page = Page.new(create_page_attributes)
    respond_with @page do |format|
      format.html { handle_html_response { @page.save } }
      format.json { handle_json_response { @page.save } }
    end
  end

  def update
    @page = resource
    attrs = update_page_attributes
    attrs = attrs.merge(path: 'home') if @page.path == '/' || @page.path.blank? # TODO: Legacy, remove
    respond_with @page do |format|
      format.html do
        handle_html_response { @page.update_attributes(attrs) }
      end
      format.json { handle_json_response { @page.update_attributes(attrs) } }
    end
  end

  private

  def resource
    Page.where(id: params[:id]).includes(:translated_contents).first ||
      Page.for_conference(@conference).with_path(path).includes(:translated_contents).first
  end

  def path
    params[:path] || 'home'
  end

  def resource_class
    Page
  end

  def create_page_attributes
    attrs = params.require(:page).permit(:path, :show_in_menu, translated_contents_attributes: %i(language title content))
    attrs.merge(conference_id: @conference.id)
  end

  def update_page_attributes
    params.require(:page).permit(:show_in_menu, translated_contents_attributes: %i(id language title content))
  end

  def handle_html_response
    result = yield
    if result
      redirect_to conference_page_path(@conference, @page)
    else
      render_conference_page_for_error
    end
  end

  def render_conference_page_for_error
    @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
    @new_track = Track.new(conference: @conference)
    @new_session_type = SessionType.new(conference: @conference)
    @new_audience_level = AudienceLevel.new(conference: @conference)
    @new_page = @page
    @conference.supported_languages.each do |code|
      @new_session_type.translated_contents.build(language: code)
      @new_audience_level.translated_contents.build(language: code)
      @new_track.translated_contents.build(language: code)
    end

    missing_langs = @conference.supported_languages - @new_page.translated_contents.map(&:language)
    missing_langs.each do |code|
      @new_page.translated_contents.build(language: code)
    end
    flash.now[:error] = 'Something went wrong'
    render template: 'conferences/edit'
  end

  def handle_json_response
    result = yield
    json_page = {
      path: @page.path,
      show_in_menu: @page.show_in_menu?,
      translations: @conference.languages.map do |l|
        c = @page.translated_contents.where(language: l[:code]).first
        { id: c.id, title: c.title, description: c.content, language: l }
      end
    }
    if result
      render json: json_page.merge(id: @page.id)
    else
      render json: json_page.merge(errors: @page.errors)
    end
  end
end
