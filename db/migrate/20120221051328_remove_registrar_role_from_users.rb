class RemoveRegistrarRoleFromUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.remove_role :registrar
      user.save!
    end
  end

  def down
  end
end
