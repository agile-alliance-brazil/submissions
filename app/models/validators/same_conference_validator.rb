# encoding: UTF-8
class SameConferenceValidator < ActiveModel::EachValidator
  def initialize(options)
    options[:message] ||= :same_conference
    super(options)
  end

  def validate_each(record, attribute, value)
    normalized = attribute.to_s.sub(/_id$/, "").to_sym
    association = record.class.reflect_on_association(normalized)
    model = record.send(association.name)

    target = options[:target] ? record.send(options[:target].to_sym) : record

    if model.nil? || model.conference_id != target.conference_id
      record.errors.add(attribute, options[:message])
    end
  end
end