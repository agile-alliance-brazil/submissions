class TestAbility
  include CanCan::Ability

  def initialize
    can :manage, :all
  end
end