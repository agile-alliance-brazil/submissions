class CreateSlots < ActiveRecord::Migration
  def self.up
    create_table :slots do |t|
      t.references  :session
      t.references  :track
      t.timestamp   :start_at
      t.timestamp   :end_at
      t.integer     :duration_mins
      
      t.timestamps
    end
  end

  def self.down
    drop_table :slots
  end
end
