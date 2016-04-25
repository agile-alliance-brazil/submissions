# encoding: UTF-8
class TranslatedContent < ActiveRecord::Base
  belongs_to :model, polymorphic: true

  validates :language, presence: true, uniqueness: {scope: %i(model_id model_type)}
  validates :title, presence: true
  validates :description, presence: true

  scope :for_language, -> (l) { where(language: l) }
end
