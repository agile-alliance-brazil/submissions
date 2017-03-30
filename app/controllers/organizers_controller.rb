# encoding: UTF-8
# frozen_string_literal: true

class OrganizersController < ApplicationController
  before_action :load_tracks

  def index
    @organizers = Organizer.for_conference(@conference)
                           .page(params[:page])
                           .order('organizers.created_at DESC')
                           .includes(:user, :track)
  end

  def new
    attributes = (params[:organizer] || {}).merge(conference: @conference)
    @organizer = Organizer.new(attributes)
  end

  def create
    @organizer = Organizer.new(organizer_params)
    if @organizer.save
      flash[:notice] = t('flash.organizer.create.success')
      redirect_to organizers_path(@conference)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def edit
    @organizer = resource
  end

  def update
    @organizer = resource
    if @organizer.update_attributes(organizer_params)
      flash[:notice] = t('flash.organizer.update.success')
      redirect_to organizers_path(@conference)
    else
      flash.now[:error] = t('flash.failure')
      render :edit
    end
  end

  def destroy
    organizer = resource
    organizer.destroy

    redirect_to organizers_path(@conference)
  end

  protected

  def resource_class
    Organizer
  end

  def resource
    Organizer.find(params[:id])
  end

  def organizer_params
    attributes = params.require(:organizer).permit(:user_username, :track_id)
    attributes[:conference_id] = @conference.id
    attributes
  end

  def load_tracks
    @tracks ||= @conference.tracks
  end
end
