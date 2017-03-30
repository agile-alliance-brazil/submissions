# encoding: UTF-8
# frozen_string_literal: true

class SessionAcceptanceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    case record.outcome
    when Outcome.find_by(title: 'outcomes.accept.title')
      record.errors.add(attribute, :cant_accept) unless
        record.session.try(:pending_confirmation?) ||
        record.session.try(:can_tentatively_accept?)
    when Outcome.find_by(title: 'outcomes.reject.title')
      record.errors.add(attribute, :cant_reject) unless
        record.session.try(:rejected?) ||
        record.session.try(:can_reject?)
    end
  end
end
