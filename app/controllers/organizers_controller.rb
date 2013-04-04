# encoding: UTF-8
class OrganizersController < InheritedResources::Base
  actions :index, :new, :create, :update, :edit, :destroy
  respond_to :html

  before_filter :load_tracks

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.organizer.create.success')
        redirect_to organizers_path(@conference)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = t('flash.organizer.update.success')
        redirect_to organizers_path(@conference)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end

  def destroy
    destroy! { organizers_path(@conference) }
  end

  protected
  def resource_params
    super.tap do |attributes|
      attributes.first[:conference_id] = @conference.id
    end
  end

  def load_tracks
    @tracks ||= @conference.tracks
  end

  def collection
    @organizers ||= end_of_association_chain.
                      for_conference(@conference).
                      page(params[:page]).
                      order('organizers.created_at DESC')
  end
end
