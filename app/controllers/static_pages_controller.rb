class StaticPagesController < ApplicationController
  skip_before_filter :login_required
  
  def show
    render :action => params[:page]
  end
end