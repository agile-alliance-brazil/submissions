# frozen_string_literal: true

class CreateUserConferences < ActiveRecord::Migration
  def change
    create_table :user_conferences do |t|
      t.belongs_to :user
      t.belongs_to :conference
      t.boolean :profile_reviewed
    end
    add_index :user_conferences, :user_id
    add_index :user_conferences, :conference_id
  end
end
