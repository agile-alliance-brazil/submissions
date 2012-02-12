# encoding: UTF-8
class SessionTypesController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  
  actions :index
  
end
