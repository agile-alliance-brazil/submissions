class Attendee < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :cpf, :gender, :twitter_user, :address, :neighbourhood, :zipcode,
                  :registration_type, :status_event, :conference_id, :user_id
  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :cpf, :twitter_user, :address, :neighbourhood, :zipcode
  
  belongs_to :conference
  belongs_to :user
  
  validates_presence_of :first_name, :last_name, :email, :phone, :country, :state, :city,
                        :cpf, :gender, :address, :zipcode, :registration_type, :conference_id
  
  validates_existence_of :conference
  validates_existence_of :user, :allow_nil => true
  
  validates_length_of [:first_name, :last_name, :organization, :country, :state, :city, :neighbourhood, :twitter_user],
                      :maximum => 100, :allow_blank => true
  validates_length_of :badge_name, :maximum => 200, :allow_blank => true
  validates_length_of :address, :maximum => 300, :allow_blank => true
  validates_length_of :zipcode, :maximum => 10, :allow_blank => true
  validates_length_of :email, :within => 6..100, :allow_blank => true
  
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true
  validates_format_of :phone, :with => /\A[0-9\(\) .\-\+]+\Z/i, :allow_blank => true
  
  validates_inclusion_of :gender, :in => Gender.valid_values, :allow_blank => true
  validates_inclusion_of :registration_type, :in => RegistrationType.valid_values, :allow_blank => true
  
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
  
  state_machine :status, :initial => :pending do
    event :confirm do
      transition :pending => :confirmed
    end

    event :expire do
      transition :pending => :expired
    end
  end
end