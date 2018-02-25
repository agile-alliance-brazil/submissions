# frozen_string_literal: true

class AddSubmissionLimitToConference < ActiveRecord::Migration
  def change
    change_table :conferences do |t|
      t.integer :submission_limit, default: 0, null: false
    end
  end
end
