# encoding: UTF-8
class AddSecondAuthorToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :second_author_id, :integer
  end

  def self.down
    remove_column :sessions, :second_author_id
  end
end
