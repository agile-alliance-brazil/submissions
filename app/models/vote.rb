class Vote < ActiveRecord::Base
  attr_accessible :session_id, :user_id, :year

  belongs_to :session
  belongs_to :user

  def self.vote_in_session(user, session)
    where(:user_id => user.id, :session_id => session.id).first
  end

end
