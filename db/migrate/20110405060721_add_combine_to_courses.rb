class AddCombineToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :combine, :boolean
  end

  def self.down
    remove_column :courses, :combine
  end
end
