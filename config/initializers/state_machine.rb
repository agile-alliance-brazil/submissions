# frozen_string_literal: true

# Rails 4.1.0.rc1 and StateMachine don't play nice
# https://github.com/pluginaweek/state_machine/issues/295
require 'state_machine/version'

unless StateMachine::VERSION == '1.2.0'
  # If you see this message, please test removing this file
  # If it's still required, please bump up the version above
  Rails.logger.warn 'Please remove me, StateMachine version has changed'
end

module StateMachine
  module Integrations
    module ActiveModel
      public :around_validation
    end
  end
end

module ActiveRecord
  # HACK: to set state_machine initial states as default attributes with Rails 4
  module ModelSchema
    module ClassMethods
      private

      def raw_default_values
        result = columns_hash.transform_values(&:default)

        state_machines.initialize_states(nil, static: :force, dynamic: false, to: result) if respond_to?(:state_machines)

        result
      end
    end
  end

  # HACK: to store state_machine initial states in DB too with Rails 4
  module AttributeMethods
    private

    def attributes_for_create(attribute_names)
      state_machine_attributes = if self.class.respond_to?(:state_machines)
                                   self.class.state_machines.keys.map(&:to_s)
                                 else
                                   []
                                 end

      (attribute_names + state_machine_attributes).uniq.reject do |name|
        pk_attribute?(name) && id.nil?
      end
    end
  end
end
