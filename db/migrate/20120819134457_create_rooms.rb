# encoding: UTF-8
# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string      :name
      t.integer     :capacity
      t.references  :conference

      t.timestamps
    end
  end
end
