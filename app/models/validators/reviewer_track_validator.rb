# encoding: UTF-8
class ReviewerTrackValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :organizer_track) unless record.reviewer.can_review?(record.track)
  end
end