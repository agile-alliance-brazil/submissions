# encoding: UTF-8
class AddDefaultLocaleToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :default_locale, :string, :default => 'pt'
    # There no attendee anymore
    # Attendee.update_all("default_locale = 'pt'", "country = 'BR'")
    # Attendee.update_all("default_locale = 'en'", "country <> 'BR'")
  end

  def self.down
    remove_column :attendees, :default_locale
  end
end
