class CreateRegistrationPeriod < ActiveRecord::Migration
  def self.up
    create_table :registration_periods do |t|
      t.references :conference
      
      t.datetime :start_at
      t.datetime :end_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :registration_periods
  end
end
