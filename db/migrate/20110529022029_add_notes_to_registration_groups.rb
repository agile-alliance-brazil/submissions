class AddNotesToRegistrationGroups < ActiveRecord::Migration
  def self.up
    add_column :registration_groups, :notes, :text
  end

  def self.down
    remove_column :registration_groups, :notes
  end
end
