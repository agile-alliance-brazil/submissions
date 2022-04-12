# frozen_string_literal: true

class AddAgilityExperienceToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string 'agility_experience'
    end
  end
end
