class AddTrackIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :track_id, :integer
  end

  def self.down
    remove_column :sessions, :track_id
  end
end
