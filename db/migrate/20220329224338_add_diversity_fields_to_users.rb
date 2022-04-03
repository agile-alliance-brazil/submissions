# frozen_string_literal: true

class AddDiversityFieldsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string 'gender'
      t.string 'race'
      t.string 'disabilities'
      t.datetime 'date_of_birth'
      t.string 'parenting_type'
      t.string 'geographical_area'
    end
  end
end
