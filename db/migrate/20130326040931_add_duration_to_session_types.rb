# frozen_string_literal: true
class AddDurationToSessionTypes < ActiveRecord::Migration
  def change
    add_column :session_types, :valid_durations, :string
  end
end
