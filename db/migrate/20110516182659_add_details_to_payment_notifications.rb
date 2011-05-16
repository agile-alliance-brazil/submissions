class AddDetailsToPaymentNotifications < ActiveRecord::Migration
  def self.up
    add_column :payment_notifications, :payer_email, :string
    add_column :payment_notifications, :settle_amount, :decimal
    add_column :payment_notifications, :settle_currency, :string
  end

  def self.down
    remove_column :payment_notifications, :settle_currency
    remove_column :payment_notifications, :settle_amount
    remove_column :payment_notifications, :payer_email
  end
end
