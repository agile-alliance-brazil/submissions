class AddVoterToUser < ActiveRecord::Migration
  def change
    add_column :users, :voter, :boolean
  end
end
