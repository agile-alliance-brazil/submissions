class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :title
      t.text :summary
      t.text :description
      t.text :mechanics
      t.text :benefits
      t.string :target_audience
      t.string :audience_limit
      t.integer :author_id
      t.text :experience
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :sessions
  end
end