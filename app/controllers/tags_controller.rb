class TagsController < InheritedResources::Base
  defaults :resource_class => ActsAsTaggableOn::Tag
  skip_before_filter :login_required
  actions :index
  respond_to :js  
  has_scope :named_like, :as => 'q'
end
