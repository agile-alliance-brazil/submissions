class DropSlots < ActiveRecord::Migration
  def up
    drop_table :slots
  end

  def down
    create_table :slots do |t|
      t.references  :session
      t.references  :track
      t.timestamp   :start_at
      t.timestamp   :end_at
      t.integer     :duration_mins
      
      t.timestamps
    end
  end
end
