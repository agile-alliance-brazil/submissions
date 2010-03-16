class AudienceLevelsController < InheritedResources::Base
  skip_before_filter :login_required
  
  actions :index
  
end