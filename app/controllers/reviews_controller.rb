class ReviewsController < InheritedResources::Base
  actions :all, :except => [:destroy]
  has_scope :for_user, :only => :index, :as => 'user_id'
  before_filter :load_reviewer
  before_filter :load_comment, :only => :show
  has_scope :tagged_with, :only => :index

  def create
  end
  
  def update
  end
end