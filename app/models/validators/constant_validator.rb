# encoding: UTF-8
class ConstantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :constant) if record.send("#{attribute}_changed?")
  end
end
