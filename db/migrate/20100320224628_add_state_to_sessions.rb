class AddStateToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :state, :string
    Session.update_all("state = 'created'")
  end

  def self.down
    remove_column :sessions, :state
  end
end
