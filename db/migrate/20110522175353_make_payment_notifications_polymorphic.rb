# encoding: UTF-8
class MakePaymentNotificationsPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :payment_notifications, :attendee_id, :invoicer_id
    add_column :payment_notifications, :invoicer_type, :string

    # There no payment notification anymore
    # PaymentNotification.update_all("invoicer_type='Attendee'")
  end

  def self.down
    remove_column :payment_notifications, :invoicer_type
    rename_column :payment_notifications, :invoicer_id, :attendee_id
  end
end
