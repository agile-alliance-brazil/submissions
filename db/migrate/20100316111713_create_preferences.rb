class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.references :reviewer
      t.references :track
      t.references :audience_level
      t.boolean :accepted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
