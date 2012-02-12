# encoding: UTF-8
class MigrateUsersFromAutholgicToDevise < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_password_token, :string
    add_column :users, :authentication_token, :string
    add_column :users, :sign_in_count, :integer

    rename_column :users, :crypted_password, :encrypted_password
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :last_request_at
  end

  def self.down
    add_column :users, :last_request_at, :datetime
    add_column :users, :perishable_token, :string
    add_column :users, :persistence_token, :string

    rename_column :users, :last_sign_in_ip, :last_login_ip
    rename_column :users, :current_sign_in_ip, :current_login_ip
    rename_column :users, :last_sign_in_at, :last_login_at
    rename_column :users, :current_sign_in_at, :current_login_at
    rename_column :users, :encrypted_password, :crypted_password

    remove_column :users, :sign_in_count
    remove_column :users, :authentication_token
    remove_column :users, :reset_password_token
  end
end
