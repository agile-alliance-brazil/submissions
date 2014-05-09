class AddPrerequisitesToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :prerequisites, :string
  end
end
