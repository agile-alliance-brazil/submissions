# encoding: UTF-8
class ReviewersController < InheritedResources::Base
  actions :index, :new, :create, :destroy, :update
  respond_to :html
  
  def index
    @tracks = current_conference.tracks
    index!
  end
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.reviewer.create.success')
        redirect_to reviewers_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def update
    params[:reviewer][:state_event] = 'accept' if params[:reviewer]
    update! do |success, failure|
      success.html do
        flash[:notice] = t('flash.reviewer.accept.success')
        redirect_to reviewer_sessions_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render 'accept_reviewers/show'
      end
    end
  end  
  
  protected
  def build_resource
    attributes = params[:reviewer] || {}
    attributes[:conference_id] = current_conference.id
    @reviewer ||= end_of_association_chain.send(method_for_build, attributes)
  end

  def collection
    @reviewers ||= Reviewer.for_conference(current_conference).joins(:user).order('first_name, last_name')
  end
end
