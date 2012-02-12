# encoding: UTF-8
class RemoveUserFromAttendee < ActiveRecord::Migration
  def self.up
    remove_column :attendees, :user_id
  end

  def self.down
    add_column :attendees, :user_id, :integer
  end
end
