# encoding: UTF-8
class ConferencesController < ApplicationController
  def index
    @conferences = Conference.order('conferences.created_at DESC').all
  end

  def new
    attributes = (params[:conference] && new_conference_params) || {}
    @conference = Conference.new(attributes)
  end

  def create
    @conference = Conference.new(new_conference_params)
    page = @conference.pages.build(path: 'home')
    @conference.languages.each do |language|
      page.translated_contents.build(title: I18n.t('title.home'), description: language[:name], language: language[:code])
    end
    if @conference.save
      flash[:notice] = I18n.t('flash.conference.create.success')
      redirect_to conference_root_path(@conference.year)
    else
      flash.now[:error] = I18n.t('flash.failure')
      render :new
    end
  end

  def edit
    @conference = resource_query.includes(pages: [:translated_contents],
      tracks: [:translated_contents],
      audience_levels: [:translated_contents],
      session_types: [:translated_contents]).first
    @new_track = Track.new(conference: @conference)
    @new_session_type = SessionType.new(conference: @conference)
    @new_audience_level = AudienceLevel.new(conference: @conference)
    @new_page = Page.new(conference: @conference)
    @conference.supported_languages.each do |code|
      @new_track.translated_contents.build(language: code)
      @new_session_type.translated_contents.build(language: code)
      @new_audience_level.translated_contents.build(language: code)
    end
  end

  def update
    @conference = resource
    if @conference.update_attributes(conference_params)
      flash[:notice] = I18n.t('flash.conference.update.success')
      redirect_to conference_root_path(@conference.year)
    else
      flash.now[:error] = I18n.t('flash.failure')
      render :edit
    end
  end

  protected
  def resource_class
    Conference
  end

  def resource
    resource_query.first
  end

  def resource_query
    Conference.where(year: (params[:id] || params[:year] || Conference.current.year))
  end

  def new_conference_params
    attributes = params.require(:conference).permit(:year, :name, :program_chair_user_username, supported_languages: [])
    attributes.merge(visible: false)
  end

  def conference_params
    params.require(:conference).permit(:logo, :location, :start_date, :end_date, :call_for_papers,
      :submissions_open, :presubmissions_deadline, :prereview_deadline, :submissions_deadline,
      :review_deadline, :author_notification, :author_confirmation, :voting_deadline, :visible)
  end
end
