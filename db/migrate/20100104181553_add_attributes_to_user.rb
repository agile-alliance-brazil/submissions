# encoding: UTF-8
class AddAttributesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :organization, :string
    add_column :users, :website_url, :string
    add_column :users, :bio, :text
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :phone
    remove_column :users, :state
    remove_column :users, :city
    remove_column :users, :organization
    remove_column :users, :website_url
    remove_column :users, :bio
  end
end
