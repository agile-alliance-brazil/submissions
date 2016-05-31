# encoding: UTF-8
class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string      :name
      t.integer     :capacity
      t.references  :conference

      t.timestamps null: false
    end
  end
end
