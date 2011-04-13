class AddCourseAttendancesCountToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :course_attendances_count, :integer, :default => 0

    Attendee.reset_column_information
    Attendee.all.each do |a|
      Attendee.update_counters a.id, :course_attendances_count => a.course_attendances.length
    end
  end

  def self.down
    remove_column :attendees, :course_attendances_count
  end
end
