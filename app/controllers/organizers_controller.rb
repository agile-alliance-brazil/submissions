# encoding: UTF-8
class OrganizersController < InheritedResources::Base
  actions :index, :new, :create, :update, :edit, :destroy
  respond_to :html
  
  before_filter :load_tracks
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.organizer.create.success')
        redirect_to organizers_path
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
        redirect_to organizers_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end
  
  protected
  def build_resource
    attributes = params[:organizer] || {}
    attributes[:conference_id] = current_conference.id
    @organizer ||= end_of_association_chain.send(method_for_build, attributes)
  end
  
  def load_tracks
    @tracks ||= current_conference.tracks
  end

  def collection
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'organizers.created_at DESC'
    @organizers ||= end_of_association_chain.for_conference(current_conference).paginate(paginate_options)
  end
end
