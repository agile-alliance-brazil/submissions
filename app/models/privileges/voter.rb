#encoding:utf-8
class Privileges::Voter < Privileges::Base
  def privileges
    can(:read, Vote, :user_id => @user.id)
    can!(:create, Vote) do |session|
      @conference.in_voting_phase? && Vote.within_limit?(@user, @conference) && !session.try(:is_author?, @user)
    end
    can(:destroy, Vote) do |vote|
      @conference.in_voting_phase? && vote.user == @user
    end
  end
end
