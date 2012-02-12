# encoding: UTF-8
class UsersController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  has_scope :search, :only => :index, :as => 'q'
  defaults :instance_name => 'user_profile'

  actions :index, :show

  def index
    index! do |format|
      format.html { redirect_to new_user_registration_path }
      format.js
    end
  end
end
