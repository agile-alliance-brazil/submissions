# frozen_string_literal: true

class AddDiversityFieldsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string 'gender'
      t.string 'race'
      t.string 'disability'
      t.datetime 'birth_date'
      t.string 'is_parent'
      t.string 'home_geographical_area'
    end
  end
end
