# encoding: UTF-8
# frozen_string_literal: true
class ReviewerTrackValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :organizer_track) unless record.reviewer.can_review?(record.track)
  end
end
