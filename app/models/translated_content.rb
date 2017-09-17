# frozen_string_literal: true

class TranslatedContent < ApplicationRecord
  belongs_to :model, polymorphic: true

  validates :language, presence: true, uniqueness: { scope: %i[model_id model_type] }
  validates :title, presence: true
  validates :content, presence: true

  scope(:for_language, ->(l) { where(language: l) })

  def content
    self[:content] || self[:description]
  end

  def description=(desc)
    STDERR.puts 'Deprecated usage. Please use #content= instead. Called from: '
    STDERR.puts caller
    self[:content] = desc
    self[:description] = 'Deprecated. This value has been migrated to content.'
  end

  def description
    STDERR.puts 'Deprecated usage. Please use #content= instead. Called from: '
    STDERR.puts caller
    self[:content] || self[:description]
  end
end
