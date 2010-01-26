class AddRolesMaskToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :roles_mask, :integer
    User.all.each do |u|
      u.add_role :author
      u.save!
    end
  end

  def self.down
    remove_column :users, :roles_mask
  end
end
