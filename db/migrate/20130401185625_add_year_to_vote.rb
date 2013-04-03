class AddYearToVote < ActiveRecord::Migration
  def change
    add_column :votes, :year, :integer
  end
end
