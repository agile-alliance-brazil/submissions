class CommentsController < InheritedResources::Base
  before_filter :login_required

  belongs_to :session
  
  actions :all, :except => [:new]
  
  def index
    redirect_to session_path(parent, :anchor => 'comments')
  end
  
  def show
    redirect_to edit_session_comment_path(@comment.commentable, @comment)
  end
  
  def create
    create! do |success, failure|
      success.html do
        redirect_to session_path(@comment.commentable, :anchor => 'comments')
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        @session = parent.reload
        render 'sessions/show'
      end
    end
  end
  
  def update
    update! do |success, failure|
      success.html do
        redirect_to session_path(@comment.commentable, :anchor => 'comments')
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        @session = parent.reload
        render :edit
      end
    end
  end  
  
  def destroy
    destroy! do |format|
      format.html do
        redirect_to session_path(@comment.commentable, :anchor => 'comments')
      end
    end
  end
  
end