class RenameRegistrationTypeOnAttendees < ActiveRecord::Migration
  def self.up
    rename_column :attendees, :registration_type, :registration_type_value
  end

  def self.down
    rename_column :attendees, :registration_type_value, :registration_type
  end
end
