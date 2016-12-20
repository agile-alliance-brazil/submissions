# frozen_string_literal: true
class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user
      t.references :session
      t.references :conference

      t.timestamps
    end
  end
end
