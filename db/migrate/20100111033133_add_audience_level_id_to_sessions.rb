class AddAudienceLevelIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :audience_level_id, :integer
  end

  def self.down
    remove_column :sessions, :audience_level_id
  end
end
