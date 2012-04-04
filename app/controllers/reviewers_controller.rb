# encoding: UTF-8
class ReviewersController < InheritedResources::Base
  actions :index, :new, :create, :destroy
  respond_to :html
  
  def index
    @tracks = @conference.tracks
    index!
  end
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.reviewer.create.success')
        redirect_to reviewers_path(@conference)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
    
  def destroy
    destroy! { reviewers_path(@conference) }
  end
  
  protected
  def build_resource
    attributes = params[:reviewer] || {}
    attributes[:conference_id] = @conference.id
    @reviewer ||= end_of_association_chain.send(method_for_build, attributes)
  end

  def collection
    @reviewers ||= Reviewer.for_conference(@conference).joins(:user).order('first_name, last_name')
  end
end
