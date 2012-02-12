# encoding: UTF-8
class AddContactNameToRegistrationGroups < ActiveRecord::Migration
  def self.up
    add_column :registration_groups, :contact_name, :string
  end

  def self.down
    remove_column :registration_groups, :contact_name
  end
end
