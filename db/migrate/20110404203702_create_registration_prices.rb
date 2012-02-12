# encoding: UTF-8
class CreateRegistrationPrices < ActiveRecord::Migration
  def self.up
    create_table :registration_prices do |t|
      t.references :registration_type
      t.references :registration_period
      
      t.decimal :value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :registration_prices
  end
end
