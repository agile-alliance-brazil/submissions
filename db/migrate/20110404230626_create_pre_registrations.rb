class CreatePreRegistrations < ActiveRecord::Migration
  def self.up
    create_table :pre_registrations do |t|
      t.references :conference
      
      t.string :email
      t.boolean :used
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pre_registrations
  end
end
