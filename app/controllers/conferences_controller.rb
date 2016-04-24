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
    @conference.languages.each do |language|
      @conference.pages.build(path: 'home', title: I18n.t('title.home'), content: language[:name], language: language[:code])
    end
    if @conference.save
      flash[:notice] = t('flash.conference.create.success')
      redirect_to conference_root_path(@conference.year)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def edit
    @conference = resource_query.includes(:pages).first
  end

  def update
    @conference = resource
    if @conference.update_attributes(conference_params)
      flash[:notice] = t('flash.conference.update.success')
      redirect_to conference_root_path(@conference.year)
    else
      flash.now[:error] = t('flash.failure')
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
