# frozen_string_literal: true

class AddTagLimitToConference < ActiveRecord::Migration
  def change
    change_table :conferences do |t|
      t.integer :tag_limit, default: 0, null: false
    end
  end
end
