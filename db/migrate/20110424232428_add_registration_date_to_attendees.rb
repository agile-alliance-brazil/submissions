class AddRegistrationDateToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :registration_date, :datetime
    
    Attendee.update_all('registration_date = created_at')
  end

  def self.down
    remove_column :attendees, :registration_date
  end
end
