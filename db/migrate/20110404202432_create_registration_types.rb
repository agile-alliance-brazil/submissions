# encoding: UTF-8
class CreateRegistrationTypes < ActiveRecord::Migration
  def self.up
    create_table :registration_types do |t|
      t.references :conference
      
      t.string :title
      
      t.timestamps
    end
  end

  def self.down
    drop_table :registration_types
  end
end
