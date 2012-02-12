# encoding: UTF-8
module Trimmer
  # Make a class method available to define space-trimming behavior.
  def self.included base
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Register a before-validation handler for the given fields to
    # trim leading and trailing spaces.
    def attr_trimmed(*attrs)
      before_validation do |model|
        attrs.each do |attr|
          model[attr] = model[attr].strip if model[attr].respond_to?('strip')
        end
      end
    end
  end
end
