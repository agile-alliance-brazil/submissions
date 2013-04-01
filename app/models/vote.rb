class Vote < ActiveRecord::Base
  attr_accessible :session_id, :user_id, :year

  belongs_to :session
  belongs_to :user
end
