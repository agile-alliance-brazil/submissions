# encoding: UTF-8
# frozen_string_literal: true

class TagsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    collection = ActsAsTaggableOn::Tag.named_like(params[:term]).all
    respond_to do |format|
      format.json { render json: collection.map(&:name) }
    end
  end

  private

  def resource_class
    ActsAsTaggableOn::Tag
  end
end
