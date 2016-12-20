# frozen_string_literal: true
class AddSeparateLocationAndStartAndEndDatesForConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :location, :string, default: nil
    add_column :conferences, :start_date, :datetime, default: nil
    add_column :conferences, :end_date, :datetime, default: nil
  end
end
