# encoding: UTF-8
class Track < ActiveRecord::Base
  belongs_to :conference
  has_many :sessions
  has_many :track_ownerships, class_name: 'Organizer'
  has_many :organizers, through: :track_ownerships, source: :user
  has_many :translated_contents, as: :model
  accepts_nested_attributes_for :translated_contents

  validates :conference, presence: true
  validate :contents_matching_conference_languages

  scope :for_conference, -> (c) { where(conference_id: c.id) }

  def title
    translated_contents.find{|c| c.language.to_sym == I18n.locale.to_sym}.try(:title) || self[:title] || ''
  end

  def description
    translated_contents.find{|c| c.language.to_sym == I18n.locale.to_sym}.try(:description) || self[:description] || ''
  end

  def experience_report?
    self.title == 'tracks.experience_reports.title'
  end

  private

  def contents_matching_conference_languages
    translated_languages = translated_contents.map(&:language).map(&:to_sym)
    missing_languages = (conference.try(:supported_languages) || []) - translated_languages
    unless missing_languages.empty?
      errors.add(:translated_contents, t('activerecord.models.translated_content.missing_languages', languages: missing_languages.join(', ')))
    end
  end
end
