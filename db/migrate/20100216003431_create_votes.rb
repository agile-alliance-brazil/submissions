# encoding: UTF-8
class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.references :user
      t.references :logo
      t.string :user_ip
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :votes
  end
end
