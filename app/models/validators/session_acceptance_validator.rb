# encoding: UTF-8
class SessionAcceptanceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    case record.outcome
    when Outcome.find_by_title('outcomes.accept.title')
      record.errors.add(attribute, :cant_accept) unless record.session.pending_confirmation? || record.session.try(:can_tentatively_accept?)
    when Outcome.find_by_title('outcomes.reject.title')
      record.errors.add(attribute, :cant_reject) unless record.session.rejected? || record.session.try(:can_reject?)
    end
  end
end