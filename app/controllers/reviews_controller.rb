# encoding: UTF-8
class ReviewsController < InheritedResources::Base
  actions :all, :except => [:edit, :update, :destroy]
  respond_to :html

  belongs_to :session
  
  def index
    index! do |format|
      format.html { render :author }
    end
  end
  
  def organizer
    index! do |format|
      format.html { render :organizer }
    end
  end
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.review.create.success')
        redirect_to session_review_path(@session, @review)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end

  protected
  def build_resource
    attributes = params[:review] || {}
    attributes[:reviewer_id] = current_user.id
    @review ||= end_of_association_chain.send(method_for_build, attributes)
  end
end
