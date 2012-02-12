# encoding: UTF-8
class AddUriTokenToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :uri_token, :string
    
    Attendee.all.each do |attendee|
      attendee.send(:generate_uri_token)
      attendee.save!(:validate => false)
    end
  end

  def self.down
    remove_column :attendees, :uri_token
  end
end
