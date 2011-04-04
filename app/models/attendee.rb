class Attendee < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :email_confirmation, :organization, :phone,
                  :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address,
                  :neighbourhood, :zipcode, :registration_type_value, :status_event, :conference_id
  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :twitter_user, :address, :neighbourhood, :zipcode
  
  belongs_to :conference
  belongs_to :registration_type
  
  has_many :registration_prices, :through => :registration_type
  
  validates_presence_of :first_name, :last_name, :email, :phone, :country, :city,
                        :gender, :address, :zipcode, :registration_type_id, :conference_id
  validates_presence_of :organization, :if => :student?
  validates_presence_of :cpf, :state, :if => Proc.new {|a| a.country == 'BR'}
  usar_como_cpf :cpf
  
  validates_existence_of :conference
  
  validates_length_of [:first_name, :last_name, :organization, :country, :state, :city, :neighbourhood, :twitter_user],
                      :maximum => 100, :allow_blank => true
  validates_length_of :badge_name, :maximum => 200, :allow_blank => true
  validates_length_of :address, :maximum => 300, :allow_blank => true
  validates_length_of :zipcode, :maximum => 10, :allow_blank => true
  validates_length_of :email, :within => 6..100, :allow_blank => true
  
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true
  validates_format_of :phone, :with => /\A[0-9\(\) .\-\+]+\Z/i, :allow_blank => true
  
  validates_inclusion_of :gender, :in => Gender.valid_values, :allow_blank => true
  validates_inclusion_of :registration_type_id, :in => RegistrationType.valid_values, :allow_blank => true
  
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
  validates_uniqueness_of :cpf, :allow_blank => true
  
  validates_confirmation_of :email
  
  def twitter_user=(value)
    self[:twitter_user] = value.start_with?("@") ? value[1..-1] : value
  end
  
  state_machine :status, :initial => :pending do
    event :confirm do
      transition :pending => :confirmed
    end

    event :expire do
      transition :pending => :expired
    end
  end
  
  def full_name
    [self.first_name, self.last_name].join(' ')
  end
  
  def student?
    registration_type_id == 1
  end
  
  def male?
    gender == 'M'
  end
  
  def registration_fee(datetime)
    registration_prices.to_s
    # prices = registration_prices.select {|p| p.registration_period.include? datetime}
    #   prices.size > 0 ? prices.first.value : nil
  end
end