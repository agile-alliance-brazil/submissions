# frozen_string_literal: true

class ConstantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :constant) if record.send("#{attribute}_changed?")
  end
end
