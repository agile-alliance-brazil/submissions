class AddDefaultLocaleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_locale, :string, :default => 'pt'
    User.update_all("default_locale = 'pt'")
  end

  def self.down
    remove_column :users, :default_locale
  end
end
