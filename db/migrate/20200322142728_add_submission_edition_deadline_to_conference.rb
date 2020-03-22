# frozen_string_literal: true

class AddSubmissionEditionDeadlineToConference < ActiveRecord::Migration
  def change
    change_table :conferences do |t|
      t.datetime :submissions_edition_deadline
    end
  end
end
