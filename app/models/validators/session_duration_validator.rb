# frozen_string_literal: true

class SessionDurationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid_durations = record.session_type.try(:valid_durations) || []
    return if value.in?(valid_durations)

    error_message = valid_durations.join(" #{I18n.t('generic.or')} ")
    record.errors.add(attribute, :session_type_duration, valid_durations: error_message)
  end
end
