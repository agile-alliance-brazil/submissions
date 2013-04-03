#encoding:utf-8
class Privileges::Voter < Privileges::Base
  def privileges
    can([:create, :read, :destroy], "votes")
    can!(:create, Vote) do |session|
      session.can_be_voted_by? @user
    end
  end
end
