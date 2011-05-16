class RegistrationGroup < ActiveRecord::Base
  attr_accessible :name, :cnpj, :state_inscription, :municipal_inscription,
                  :contact_name, :contact_email, :contact_email_confirmation, :phone, :fax,
                  :country, :state, :city, :address, :neighbourhood, :zipcode, :total_attendees
  attr_trimmed    :name, :state_inscription, :municipal_inscription, :contact_name, :contact_email,
                  :phone, :fax, :country, :state, :city, :address, :neighbourhood, :zipcode

  has_many :attendees

  validates_presence_of :name, :contact_name, :contact_email, :phone, :fax,
                        :country, :city, :address, :zipcode, :total_attendees
  validates_presence_of :cnpj, :state_inscription, :municipal_inscription, :state, :if => Proc.new {|a| a.country == 'BR'}
  usar_como_cnpj :cnpj
  
  validates_length_of [:name, :country, :state, :city, :neighbourhood, :contact_name],
                      :maximum => 100, :allow_blank => true
  validates_length_of :address, :maximum => 300, :allow_blank => true
  validates_length_of :zipcode, :maximum => 10, :allow_blank => true
  validates_length_of :contact_email, :within => 6..100, :allow_blank => true
  
  validates_format_of :contact_email, :with => Devise.email_regexp, :allow_blank => true
  validates_format_of :phone, :fax, :with => /\A[0-9\(\) .\-\+]+\Z/i, :allow_blank => true
  
  validates_numericality_of :total_attendees, :only_integer => true, :greater_than_or_equal_to => 5, :allow_blank => true
  
  validates_uniqueness_of :cnpj, :allow_blank => true
  
  validates_confirmation_of :contact_email
  
  def complete?
    attendees.size >= total_attendees
  end
  
  def registration_fee
    attendees.map {|attendee| attendee.registration_fee}.sum(0.0)
  end
  
  def registration_period
    return nil if attendees.empty?
    periods = RegistrationPeriod.for(attendees.first.registration_date)
    attendees.any?(&:pre_registered?) ? periods.last : periods.first
  end
  
  def to_param
    name.blank? ? super : "#{id}-#{name.parameterize}"
  end
end