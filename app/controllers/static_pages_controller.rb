# encoding: UTF-8
class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    render :action => "#{@conference.year}_#{params[:page]}"
  end
end
