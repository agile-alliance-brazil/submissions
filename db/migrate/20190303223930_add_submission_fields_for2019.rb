# frozen_string_literal: true

class AddSubmissionFieldsFor2019 < ActiveRecord::Migration
  def change
    change_table :sessions do |t|
      t.string :video_link, default: nil, null: true
      t.text :additional_links, default: nil, null: true
      t.boolean :first_presentation, default: false, null: false
      t.text :presentation_justification, default: nil, null: true
    end
  end
end
