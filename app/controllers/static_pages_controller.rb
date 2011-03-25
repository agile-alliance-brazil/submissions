class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def show
    render :action => params[:page]
  end
end