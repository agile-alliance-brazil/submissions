# encoding: UTF-8
class Page < ActiveRecord::Base
  belongs_to :conference
  has_many :translated_contents, as: :model, dependent: :destroy
  accepts_nested_attributes_for :translated_contents

  validates :conference, presence: true
  validates :path, presence: true, uniqueness: { scope: %i(conference_id) }
  validate :contents_matching_conference_languages

  scope :for_conference, -> (c) { where(conference: c.is_a?(ActiveRecord::Base) ? c.id : c) }
  scope :with_path, -> (p) { where(path: p) }
  scope :with_language, -> (l) { where(language: l) }

  def title
    translated_contents.find {|c| c.language.to_sym == I18n.locale.to_sym}.try(:title) || I18n.t(self[:title] || '')
  end

  def content
    translated_contents.find {|c| c.language.to_sym == I18n.locale.to_sym}.try(:content) || I18n.t(self[:content] || '')
  end

  def to_params
    path.gsub(/^\//, '')
  end

  private

  def contents_matching_conference_languages
    translated_languages = translated_contents.map(&:language).map(&:to_sym)
    missing_languages = (conference.try(:supported_languages) || []) - translated_languages
    unless missing_languages.empty?
      error_message = I18n.t('activerecord.models.translated_content.missing_languages', languages: missing_languages.join(', '))
      errors.add(:translated_contents, languages: error_message)
    end
  end
end
