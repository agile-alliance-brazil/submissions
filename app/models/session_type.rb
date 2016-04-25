# encoding: UTF-8
class SessionType < ActiveRecord::Base
  has_many :sessions
  belongs_to :conference
  has_many :translated_contents, as: :model
  accepts_nested_attributes_for :translated_contents
  serialize :valid_durations, Array

  validates :conference, presence: true
  validate :contents_matching_conference_languages

  scope :for_conference, -> (c) { where(conference_id: c.id) }

  def title
    translated_contents.for_language(I18n.locale).first.try(:title) || self[:title]
  end

  def description
    translated_contents.for_language(I18n.locale).first.try(:description) || self[:description]
  end

  def self.all_titles
    self.select(:title).uniq.map do |session_type|
      session_type.title.match(/session_types\.(\w+)\.title/).try(:[], 1)
    end
  end

  def respond_to_missing?(method_sym, include_private = false)
    is_title_check_method?(method_sym) || super
  end

  def method_missing(method_sym, *arguments, &block)
    if is_title_check_method?(method_sym)
      title_matches(method_sym)
    else
      super
    end
  end

  private

  def title_matches(method_sym)
    title_name = method_sym.to_s.gsub(/\?$/,'')
    self.title == "session_types.#{title_name}.title"
  end

  def is_title_check_method?(method_sym)
    method_sym.to_s.ends_with?('?') &&
      SessionType.all_titles.
        map {|title| "#{title}?"}.
        include?(method_sym.to_s)
  end

  def contents_matching_conference_languages
    translated_languages = translated_contents.map(&:language).map(&:to_sym)
    missing_languages = conference.supported_languages - translated_languages
    unless missing_languages.empty?
      errors.add(:translated_contents, t('activerecord.models.translated_content.missing_languages', languages.join(', ')))
    end
  end
end
