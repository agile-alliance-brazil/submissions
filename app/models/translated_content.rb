# encoding: UTF-8
class TranslatedContent < ActiveRecord::Base
  belongs_to :model, polymorphic: true

  validates :language, presence: true, uniqueness: {scope: %i(model_id model_type)}
  validates :title, presence: true
  validates :description, presence: true
  validates :content, presence: true

  scope :for_language, -> (l) { where(language: l) }

  def content
    self[:content] || self[:description]
  end

  def description=(desc)
    self[:content] = desc
    self[:description] = "Deprecated. This value has been migrated to content."
  end

  def description
    ActiveSupport::Deprecation.warn('Deprecated usage of TranslatedContent#description. Please change to TranslatedContent#content')
    self[:content] || self[:description]
  end

end
