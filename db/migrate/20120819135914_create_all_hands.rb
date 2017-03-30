# encoding: UTF-8
# frozen_string_literal: true

class CreateAllHands < ActiveRecord::Migration
  def change
    create_table :all_hands do |t|
      t.string :title

      t.timestamps
    end
  end
end
