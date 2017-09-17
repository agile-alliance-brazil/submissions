# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render action: "#{@conference.year}_#{params[:page]}"
  end

  def syntax_help; end
end
