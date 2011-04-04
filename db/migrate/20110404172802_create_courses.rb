class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.references :conference
      
      t.string :name
      t.string :full_name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
