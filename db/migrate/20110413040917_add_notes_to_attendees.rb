class AddNotesToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :notes, :text
  end

  def self.down
    remove_column :attendees, :notes
  end
end
