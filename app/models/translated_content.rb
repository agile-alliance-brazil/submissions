# frozen_string_literal: true

class TranslatedContent < ApplicationRecord
  belongs_to :model, polymorphic: true, inverse_of: :translated_contents

  validates :language, presence: true, uniqueness: { scope: %i[model_id model_type] }
  validates :title, presence: true
  validates :content, presence: true

  scope(:for_language, ->(l) { where(language: l) })

  def content
    self[:content] || self[:description]
  end

  def description=(desc)
    warn 'Deprecated usage. Please use #content= instead. Called from: '
    warn caller
    self[:content] = desc
    self[:description] = 'Deprecated. This value has been migrated to content.'
  end

  def description
    warn 'Deprecated usage. Please use #content= instead. Called from: '
    warn caller
    self[:content] || self[:description]
  end
end
