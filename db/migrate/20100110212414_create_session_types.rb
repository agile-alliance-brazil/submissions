# encoding: UTF-8
class CreateSessionTypes < ActiveRecord::Migration
  def self.up
    create_table :session_types do |t|
      t.string :title
      t.string :description
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :session_types
  end
end
