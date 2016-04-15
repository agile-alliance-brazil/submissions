class AddUniquenessConstraintToYearInConferences < ActiveRecord::Migration
  def change
    add_index :conferences, :year, unique: true
  end
end
