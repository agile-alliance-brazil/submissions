# frozen_string_literal: true

class AddContentAsTextToTranslatedContents < ActiveRecord::Migration
  def change
    add_column :translated_contents, :content, :text
  end
end
