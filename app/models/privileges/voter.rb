#encoding:utf-8
class Privileges::Voter < Privileges::Base
  def privileges
    puts "========================================"
    can([:create, :read], "votes")
  end
end
