# frozen_string_literal: true

# ApplicationRecord is an extra layer of indirection to ActiveRecord::Base
# which allows us to customize its behavior per application without monkey
# patching
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
