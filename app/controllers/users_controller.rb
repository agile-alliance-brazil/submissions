class UsersController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  has_scope :search, :only => :index, :as => 'q'

  actions :index, :show

  def index
    index! do |format|
      format.html { redirect_to new_user_registration_path }
      format.js
    end
  end
end