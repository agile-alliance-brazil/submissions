class AddUriTokenToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :uri_token, :string
    
    Attendee.all.each do |attendee|
      attendee.send(:generate_uri_token)
      attendee.save!
    end
  end

  def self.down
    remove_column :attendees, :uri_token
  end
end
