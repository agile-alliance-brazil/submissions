# encoding: utf-8
module Privileges
  class Base
    delegate :can, :cannot, to: :@ability

    def initialize(ability)
      @ability = ability
      @user, @reviewer, @conference, @session = @ability.user, @ability.reviewer, @ability.conference, @ability.session
    end

    # This method forces the block execution to happen, even for actions that cancan doesn't call the block, like
    # when the action is :index or :update with a class
    def can!(expected_actions, expected_subject_classes, &block)
      can do |action, subject_class, subject, session|
        @ability.send(:expand_actions, Array[*expected_actions]).include?(action) &&
          Array[*expected_subject_classes].include?(subject_class) &&
          block.call(session || @session)
      end
    end
  end
end