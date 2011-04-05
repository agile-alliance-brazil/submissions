class AddTitleToRegistrationPeriod < ActiveRecord::Migration
  def self.up
    add_column :registration_periods, :title, :string
  end

  def self.down
    remove_column :registration_periods, :title
  end
end
