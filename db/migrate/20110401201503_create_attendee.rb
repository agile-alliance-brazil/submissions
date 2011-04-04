class CreateAttendee < ActiveRecord::Migration
  def self.up
    create_table :attendees do |t|
      t.references :conference
      
      t.string :first_name
      t.string :last_name
      t.references :user
      t.string :email
      t.string :organization
      t.string :phone
      t.string :country
      t.string :state
      t.string :city
      
      t.string :badge_name
      t.string :cpf
      t.string :gender
      t.string :twitter_user
      t.string :address
      t.string :neighbourhood
      t.string :zipcode
      
      t.string :registration_type
      t.string :status
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :attendees
  end
end
