class StaticPagesController < ApplicationController
  def show
    render :action => params[:page]
  end
end