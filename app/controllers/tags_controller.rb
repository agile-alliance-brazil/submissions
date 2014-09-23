# encoding: UTF-8
class TagsController < InheritedResources::Base
  defaults resource_class: ActsAsTaggableOn::Tag
  skip_before_filter :authenticate_user!
  actions :index
  respond_to :js
  has_scope :named_like, as: 'term'

  def index
    index! do |format|
      format.js { render json: collection.map(&:name) }
    end
  end
end
