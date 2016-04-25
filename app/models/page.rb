# encoding: UTF-8
class Page < ActiveRecord::Base
  belongs_to :conference

  validates :conference, presence: true
  validates :path, presence: true, uniqueness: {scope: %i(conference_id) }
  validates :language, presence: true, uniqueness: {scope: %i(conference_id path) }

  scope :for_conference, -> (c) { where(conference: c.is_a?(ActiveRecord::Base) ? c.id : c) }
  scope :with_path, -> (p) { where(path: p) }
  scope :with_language, -> (l) { where(language: l) }

  def to_params
    path.gsub(/^\//, '')
  end

  def self.for_path(conference, path)
    pages = Page.for_conference(conference).with_path(path).all
    page = nil
    if pages.size == 1
      page = pages.first
    elsif pages.size > 1
      page = pages.with_language(I18n.locale).first ||
        pages.with_language(conference.supported_languages.first).first ||
        pages.with_language(:en).first
    end

    page
  end
end
