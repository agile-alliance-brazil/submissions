class CreateAudienceLevels < ActiveRecord::Migration
  def self.up
    create_table :audience_levels do |t|
      t.string :title
      t.string :description
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :audience_levels
  end
end