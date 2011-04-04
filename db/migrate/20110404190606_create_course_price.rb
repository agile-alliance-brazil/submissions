class CreateCoursePrice < ActiveRecord::Migration
  def self.up
    create_table :course_prices do |t|
      t.references :course
      t.references :registration_period
      
      t.decimal :value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :course_prices
  end
end
