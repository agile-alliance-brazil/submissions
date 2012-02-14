class DowncaseUsernameOnUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update_attribute :username, user.username.downcase
    end
  end

  def down
  end
end
