class Vote < ActiveRecord::Base
  attr_accessible :session_id, :user_id, :year
end
