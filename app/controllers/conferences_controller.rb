# encoding: UTF-8
class ConferencesController < ApplicationController
  def index
    @conferences = Conference.order('conferences.created_at DESC').all
  end

  def show
    @conference = resource_query.includes(:pages).first
    if @conference.pages.with_path('/').first.nil?
      render template: "static_pages/#{@conference.year}_home"
    else
      render :show
    end
  end

  def new
    attributes = (params[:conference] && new_conference_params) || {}
    @conference = Conference.new(attributes)
  end

  def create
    @conference = Conference.new(new_conference_params)
    @conference.pages.build(path: '/', content: '')
    if @conference.save
      flash[:notice] = t('flash.conference.create.success')
      redirect_to "/#{@conference.year}"
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
      redirect_to "/#{@conference.year}"
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
    Conference.where(year: (params[:id] || params[:year] || Conference.where(visible: true).last.year))
  end

  def new_conference_params
    attributes = params.require(:conference).permit(:year, :name, :program_chair_username)
    attributes.merge(visible: false)
  end

  def conference_params
    params.require(:conference).permit(:logo, :location, :start_date, :end_date, :call_for_papers,
      :submissions_open, :presubmissions_deadline, :prereview_deadline, :submissions_deadline,
      :review_deadline, :author_notification, :author_confirmation, :voting_deadline, :visible)
  end
end
