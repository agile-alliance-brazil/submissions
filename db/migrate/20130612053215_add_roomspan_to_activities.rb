class AddRoomspanToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :roomspan, :integer, default: 1
  end
end
