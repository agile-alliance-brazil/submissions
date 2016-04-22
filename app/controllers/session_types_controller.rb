# encoding: UTF-8
class SessionTypesController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @session_types = SessionType.for_conference(@conference)
  end

  private
  def resource_class
    SessionType
  end
end
