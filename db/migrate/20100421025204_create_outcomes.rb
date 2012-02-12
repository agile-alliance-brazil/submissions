# encoding: UTF-8
class CreateOutcomes < ActiveRecord::Migration
  def self.up
    create_table :outcomes do |t|
      t.string :title
      
      t.timestamps
    end
  end

  def self.down
    drop_table :outcomes
  end
end
