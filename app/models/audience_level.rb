# frozen_string_literal: true

class AudienceLevel < ApplicationRecord
  has_many :sessions, dependent: :restrict_with_exception
  belongs_to :conference
  has_many :translated_contents, as: :model, dependent: :destroy, inverse_of: :model
  accepts_nested_attributes_for :translated_contents

  validates :conference, presence: true
  validate :contents_matching_conference_languages

  scope(:for_conference, ->(c) { where(conference_id: c.id) })

  def title
    translated_contents.find { |c| c.language.to_sym == I18n.locale.to_sym }.try(:title) || (self[:title] && I18n.t(self[:title])) || ''
  end

  def description
    translated_contents.find { |c| c.language.to_sym == I18n.locale.to_sym }.try(:content) || (self[:description] && I18n.t(self[:description])) || ''
  end

  private

  def contents_matching_conference_languages
    translated_languages = translated_contents.map(&:language).compact.map(&:to_sym)
    missing_languages = (conference.try(:supported_languages) || []) - translated_languages
    return if missing_languages.empty?

    error_message = I18n.t('activerecord.models.translated_content.missing_languages', languages: missing_languages.join(', '))
    errors.add(:translated_contents, languages: error_message)
  end
end
