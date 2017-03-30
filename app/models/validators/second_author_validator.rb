# encoding: UTF-8
# frozen_string_literal: true

class SecondAuthorValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :existence) if record.second_author.nil?
    record.errors.add(attribute, :same_author) if record.second_author == record.author
    record.errors.add(attribute, :incomplete) if record.second_author.present? && !record.second_author.try(:author?)
  end
end
