# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.datetime    :start_at
      t.datetime    :end_at
      t.references  :room
      t.references  :detail, polymorphic: true

      t.timestamps
    end
  end
end
