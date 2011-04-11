class CreateRegistrationGroups < ActiveRecord::Migration
  def self.up
    create_table :registration_groups do |t|
      t.string :name
      t.string :cnpj
      t.string :state_inscription
      t.string :municipal_inscription
      t.string :contact_email
      t.string :phone
      t.string :fax
      t.string :address
      t.string :neighbourhood
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      
      t.integer :total_attendees
      t.boolean :email_sent, :default => false

      t.timestamps
    end
    
    add_column :attendees, :registration_group_id, :integer
  end

  def self.down
    remove_column :attendees, :registration_group_id
    drop_table :registration_groups
  end
end
