# encoding: UTF-8
class CreateAllHands < ActiveRecord::Migration
  def change
    create_table :all_hands do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
