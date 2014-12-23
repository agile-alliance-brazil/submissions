# encoding: UTF-8
class TracksController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @tracks = Track.for_conference(@conference)
  end

  private
  def resource_class
    Track
  end
end
