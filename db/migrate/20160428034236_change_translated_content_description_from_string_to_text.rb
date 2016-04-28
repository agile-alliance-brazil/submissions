class ChangeTranslatedContentDescriptionFromStringToText < ActiveRecord::Migration
  def up
      change_column :translated_contents, :description, :text
  end
  def down
      change_column :translated_contents, :description, :string
  end
end
