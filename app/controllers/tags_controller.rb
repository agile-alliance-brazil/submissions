class TagsController < InheritedResources::Base
  actions :index
  respond_to :js  
  has_scope :named_like, :as => 'q'
end
