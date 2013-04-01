#encoding:utf-8
class Privileges::Voter < Privileges::Base
  def privileges
    can([:create, :read, :destroy], "votes")
  end
end
