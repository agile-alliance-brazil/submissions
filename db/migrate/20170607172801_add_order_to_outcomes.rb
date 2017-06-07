class AddOrderToOutcomes < ActiveRecord::Migration
  def change
    add_column :outcomes, :order, :integer, null: false, default: 0
  end
end
