# frozen_string_literal: true

class AddExpirationYearToTags < ActiveRecord::Migration
  def up
    add_column :tags, :expiration_year, :integer
    execute 'update tags set expiration_year=2013'
  end

  def down
    remove_column :tags, :expiration_year
  end
end
