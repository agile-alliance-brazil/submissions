class AddNotesToPaymentNotification < ActiveRecord::Migration
  def self.up
    add_column :payment_notifications, :notes, :text
  end

  def self.down
    remove_column :payment_notifications, :notes
  end
end
