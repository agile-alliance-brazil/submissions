# encoding: UTF-8
class ChangeRegistrationTypeOnAttendeeToReference < ActiveRecord::Migration
  def self.up
    add_column :attendees, :registration_type_id, :integer
    
    Attendee.all.each do |attendee|
      if attendee.registration_type_value == "individual"
        attendee.registration_type_id = 3
      else
        attendee.registration_type_id = 1
      end
    end
    
    remove_column :attendees, :registration_type_value
  end

  def self.down
    add_column :attendees, :registration_type_value, :string
    
    Attendee.all.each do |attendee|
      if attendee.registration_type_id == 3
        attendee.registration_type_value = 'individual'
      else
        attendee.registration_type_value = 'student'
      end
    end
    
    remove_column :attendees, :registration_type_id
  end
end
