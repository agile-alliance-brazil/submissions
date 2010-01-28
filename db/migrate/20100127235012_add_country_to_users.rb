class AddCountryToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :country, :string
    User.update_all("country = 'BR'")
  end

  def self.down
    remove_column :users, :country
  end
end
