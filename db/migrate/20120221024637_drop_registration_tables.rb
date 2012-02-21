class DropRegistrationTables < ActiveRecord::Migration
  def up
    drop_table :pre_registrations

    drop_table :payment_notifications
    
    drop_table :course_prices
    drop_table :course_attendances
    drop_table :courses
    
    drop_table :attendees
    
    drop_table :registration_prices
    drop_table :registration_types
    drop_table :registration_periods
    
    drop_table :registration_groups
  end

  def down
    create_table :registration_groups do |t|
      t.string   :name
      t.string   :cnpj
      t.string   :state_inscription
      t.string   :municipal_inscription
      t.string   :contact_email
      t.string   :phone
      t.string   :fax
      t.string   :address
      t.string   :neighbourhood
      t.string   :city
      t.string   :state
      t.string   :zipcode
      t.string   :country
      t.integer  :total_attendees
      t.boolean  :email_sent, :default => false
      t.timestamps
      t.string   :contact_name
      t.string   :uri_token
      t.string   :status
      t.text     :notes
    end

    create_table :registration_periods do |t|
      t.references  :conference
      t.datetime    :start_at
      t.datetime    :end_at
      t.string      :title
      t.timestamps
    end

    create_table :registration_types do |t|
      t.references  :conference
      t.string      :title
      t.timestamps
    end

    create_table :registration_prices do |t|
      t.references  :registration_type
      t.references  :registration_period
      t.decimal     :value, :precision => 10, :scale => 0
      t.timestamps
    end
    
    create_table :attendees do |t|
      t.references  :conference
      t.string      :first_name
      t.string      :last_name
      t.string      :email
      t.string      :organization
      t.string      :phone
      t.string      :country
      t.string      :state
      t.string      :city
      t.string      :badge_name
      t.string      :cpf
      t.string      :gender
      t.string      :twitter_user
      t.string      :address
      t.string      :neighbourhood
      t.string      :zipcode
      t.string      :status
      t.references  :registration_type
      t.boolean     :email_sent, :default => false
      t.references  :registration_group
      t.integer     :course_attendances_count, :default => 0
      t.text        :notes
      t.datetime    :registration_date
      t.string      :uri_token
      t.string      :default_locale, :default => "pt"
      t.timestamps
    end

    create_table :courses do |t|
      t.references  :conference
      t.string      :name
      t.string      :full_name
      t.boolean     :combine
      t.timestamps
    end

    create_table :course_attendances do |t|
      t.references  :course
      t.references  :attendee
      t.timestamps
    end

    create_table :course_prices do |t|
      t.references  :course
      t.references  :registration_period
      t.decimal     :value, :precision => 10, :scale => 0
      t.timestamps
    end

    create_table :payment_notifications do |t|
      t.text        :params
      t.string      :status
      t.string      :transaction_id
      t.references  :invoicer
      t.string      :payer_email
      t.decimal     :settle_amount, :precision => 10, :scale => 0
      t.string      :settle_currency
      t.text        :notes
      t.string      :invoicer_type
      t.timestamps
    end

    create_table :pre_registrations do |t|
      t.references  :conference
      t.string      :email
      t.boolean     :used
      t.timestamps
    end
  end
end
