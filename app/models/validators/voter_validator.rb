# frozen_string_literal: true

class VoterValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :author) if record.session.try(:is_author?, record.user)
    record.errors.add(attribute, :voter) unless record.user.try(:voter?)
  end
end
