# encoding: UTF-8
class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :show

  def show
    @page = resource
    if @page
      render :show
    else
      begin
        render template: "static_pages/#{@conference.year}_#{path}"
      rescue ActionView::MissingTemplate
        render file: "#{Rails.root}/public/404.html", layout: false, status: 404
      end
    end
  end

  def create
    @page = Page.new(create_page_attributes)
    if @page.save
      redirect_to conference_page_path(@conference, @page)
    else
      @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
      @new_track = Track.new(conference: @conference)
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @new_page = @page
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
      end
      missing_langs = @conference.supported_languages - @new_page.translated_contents.map(&:language)
      missing_langs.each do |code|
        @new_page.translated_contents.build(language: code)
      end
      flash.now[:error] = t('flash.failure')
      render template: 'conferences/edit'
    end
  end

  def update
    @page = resource
    attrs = update_page_attributes
    attrs = attrs.merge({ path: 'home' }) if @page.path == '/' || @page.path.blank? # TODO Legacy, remove
    if @page.update_attributes(attrs)
      redirect_to conference_page_path(@conference, @page)
    else
      @tags = ActsAsTaggableOn::Tag.where('name like ? and (expiration_year IS NULL or expiration_year >= ?)', 'tags.%', @conference.year).to_a
      @new_track = Track.new(conference: @conference)
      @new_session_type = SessionType.new(conference: @conference)
      @new_audience_level = AudienceLevel.new(conference: @conference)
      @new_page = @page
      @conference.supported_languages.each do |code|
        @new_track.translated_contents.build(language: code)
        @new_session_type.translated_contents.build(language: code)
        @new_audience_level.translated_contents.build(language: code)
      end
      flash.now[:error] = t('flash.failure')
      render template: 'conferences/edit'
    end
  end

  private
  def resource
    Page.where(id: params[:id]).first || Page.for_conference(@conference).with_path(path).first
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
end
