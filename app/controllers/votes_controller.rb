class VotesController < InheritedResources::Base
  before_filter :login_required
  
  actions :new, :create
  respond_to :html
  
  def index
    redirect_to new_vote_path
  end
  
  def create
    create! do |success, failure|
      success.html do
        redirect_to new_vote_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def new
    @previous_vote = Vote.for_user(current_user.id).first
    flash.now[:notice] = t('flash.vote.create.success') if @previous_vote
    new!
  end

  protected
  def build_resource
    attributes = params[:vote] || {}
    attributes[:user_id] = current_user.id
    attributes[:user_ip] = current_user.current_login_ip
    @vote ||= end_of_association_chain.send(method_for_build, attributes)
  end
end