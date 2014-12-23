# encoding: UTF-8
class AudienceLevelsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @audience_levels = AudienceLevel.for_conference(@conference)
  end

  protected
  def resource_class
    AudienceLevel
  end
end
