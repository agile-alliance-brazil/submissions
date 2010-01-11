class AddDurationToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :duration_mins, :integer
  end

  def self.down
    remove_column :sessions, :duration_mins
  end
end
