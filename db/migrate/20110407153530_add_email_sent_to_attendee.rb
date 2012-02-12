# encoding: UTF-8
class AddEmailSentToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :email_sent, :boolean, :default => false
  end

  def self.down
    remove_column :attendees, :email_sent
  end
end
