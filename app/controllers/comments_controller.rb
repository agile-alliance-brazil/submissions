# encoding: UTF-8
class CommentsController < ApplicationController
  before_filter :load_session

  def index
    redirect_to session_path(@conference, @session, anchor: 'comments')
  end

  def show
    @comment = resource
    redirect_to edit_session_comment_path(@conference, @comment.commentable, @comment)
  end

  def create
    @comment = Comment.new(comment_attributes)
    if @comment.save
      EmailNotifications.comment_submitted(@session, @comment).deliver
      redirect_to session_path(@conference, @session, anchor: 'comments')
    else
      flash.now[:error] = t('flash.failure')
      @session.reload
      render 'sessions/show'
    end
  end

  def edit
    @comment = resource
  end

  def update
    @comment = resource
    if @comment.update_attributes(comment_attributes)
      redirect_to session_path(@conference, @comment.commentable, anchor: 'comments')
    else
      flash.now[:error] = t('flash.failure')
      @session = @comment.commentable.reload
      render :edit
    end
  end

  def destroy
    @comment = resource
    @comment.destroy

    redirect_to session_path(@conference, @session, anchor: 'comments')
  end

  private
  def resource
    Comment.find(params[:id])
  end

  def comment_attributes
    attributes = params.require(:comment).permit(:comment)
    attributes.merge(inferred_attributes)
  end

  def inferred_attributes
    {
      user_id: current_user.id,
      commentable_id: @session.id
    }
  end

  def load_session
    @session = Session.find(params[:session_id])
  end
end
