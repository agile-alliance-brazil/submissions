# encoding: UTF-8
class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :show

  def show
    @page = resource
    if @page
      render :show
    else
      render template: "static_pages/#{@conference.year}_#{path}"
    end
  end

  def new
  end

  def create
    @comment = @session.comments.create(comment_attributes)
    if @comment.save
      EmailNotifications.comment_submitted(@session, @comment).deliver_now
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

  private
  def resource
    Page.where(conference_id: @conference.id, path: path).first # TODO: Find by locale
  end

  def path
    params[:path] || ''
  end

  def resource_class
    Page
  end
end
