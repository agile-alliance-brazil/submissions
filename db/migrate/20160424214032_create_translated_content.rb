class CreateTranslatedContent < ActiveRecord::Migration
  def change
    create_table :translated_contents do |t|
      t.belongs_to  :model, polymorphic: true
      t.string      :title, null: false
      t.string      :description, null: false, default: ''
      t.string      :language, null: false

      t.timestamps null: false
    end
  end
end
