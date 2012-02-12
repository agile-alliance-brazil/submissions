# encoding: UTF-8
class AddSessionTypeIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :session_type_id, :integer
  end

  def self.down
    remove_column :sessions, :session_type_id
  end
end
