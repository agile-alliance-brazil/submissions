# frozen_string_literal: true

class TestAbility
  include CanCan::Ability

  def initialize
    can :manage, :all
  end
end

module DisableAuthorization
  def disable_authorization
    @test_ability ||= TestAbility.new
    controller.stubs(:current_ability).returns(@test_ability)
  end
end
