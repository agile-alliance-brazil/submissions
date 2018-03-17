# frozen_string_literal: true

class TagsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    year = params[:year]
    collection = []
    term = sanitize(params[:term])
    tags = year ? @conference.tags.all : resource_class.all
    tag_names = tags.map do |tag|
      if I18n.exists?(tag.name, I18n.locale)
        I18n.t(tag.name)
      else
        tag.name
      end
    end
    regex = /.*#{term}.*/i
    collection = tag_names.select do |tag_name|
      regex.match(tag_name)
    end

    respond_to do |format|
      format.json { render json: collection.sort }
    end
  end

  private

  def resource_class
    ActsAsTaggableOn::Tag
  end

  def sanitize(search_term)
    search_term.gsub(/[^a-zA-Z0-9,.\s]*/, '').gsub(/\./, '\\.')
  end
end
