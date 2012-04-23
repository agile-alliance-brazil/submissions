# encoding: UTF-8
class CommentsController < InheritedResources::Base
  belongs_to :session

  actions :all, :except => [:new]

  def index
    redirect_to session_path(@conference, parent, :anchor => 'comments')
  end

  def show
    redirect_to edit_session_comment_path(@conference, @comment.commentable, @comment)
  end

  def create
    create! do |success, failure|
      success.html do
        EmailNotifications.send_comment_submitted(@comment.commentable, @comment)
        redirect_to session_path(@conference, @comment.commentable, :anchor => 'comments')
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
        redirect_to session_path(@conference, @comment.commentable, :anchor => 'comments')
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
        redirect_to session_path(@conference, @comment.commentable, :anchor => 'comments')
      end
    end
  end

end
