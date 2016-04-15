class AddVisibleToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :visible, :boolean, default: false
  end
end
