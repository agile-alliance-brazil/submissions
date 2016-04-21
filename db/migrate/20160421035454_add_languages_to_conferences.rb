class AddLanguagesToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :supported_languages, :string, null: false, default: 'en,pt'
    add_column :pages, :language, :string, null: false, default: 'pt'
  end
end
