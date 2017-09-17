# frozen_string_literal: true

module ActiveRecord
  class Base
    include Trimmer
    include AutoCompleteUsername
  end
end
