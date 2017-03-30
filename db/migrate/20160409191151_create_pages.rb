# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :conference
      t.string  :path, null: false
      t.string  :content, default: ''

      t.timestamps
    end
  end
end
