# encoding: UTF-8
# frozen_string_literal: true
class CreateGuestSessions < ActiveRecord::Migration
  def change
    create_table :guest_sessions do |t|
      t.string      :title
      t.string      :author
      t.text        :summary
      t.references  :conference
      t.boolean     :keynote, default: false

      t.timestamps
    end
  end
end
