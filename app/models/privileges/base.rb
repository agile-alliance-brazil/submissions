# frozen_string_literal: true

module Privileges
  class Base
    delegate :can, :cannot, to: :@ability

    def initialize(ability)
      @ability = ability
      @user = @ability.user
      @reviewer = @ability.reviewer
      @conference = @ability.conference
      @session = @ability.session
    end

    # This method forces the block execution to happen, even for actions that cancan doesn't call the block, like
    # when the action is :index or :update with a class
    def can!(expected_actions, expected_subject_classes)
      can do |action, subject_class, _subject, session|
        @ability.send(:expand_actions, Array[*expected_actions]).include?(action) &&
          Array[*expected_subject_classes].include?(subject_class) &&
          yield(session || @session)
      end
    end
  end
end
