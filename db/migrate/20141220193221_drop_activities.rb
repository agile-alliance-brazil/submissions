# frozen_string_literal: true

class DropActivities < ActiveRecord::Migration
  def up
    drop_table :activities
  end

  def down
    create_table :activities do |t|
      t.datetime    :start_at
      t.datetime    :end_at
      t.references  :room
      t.references  :detail, polymorphic: true

      t.timestamps
    end
  end
end
