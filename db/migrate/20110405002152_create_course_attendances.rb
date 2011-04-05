class CreateCourseAttendances < ActiveRecord::Migration
  def self.up
    create_table :course_attendances do |t|
      t.references :course
      t.references :attendee
      
      t.timestamps
    end
  end

  def self.down
    drop_table :course_attendances
  end
end
