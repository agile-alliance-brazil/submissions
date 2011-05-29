class RegistrationGroup < ActiveRecord::Base
  include TokenGenerator
  attr_accessible :name, :cnpj, :state_inscription, :municipal_inscription,
                  :contact_name, :contact_email, :contact_email_confirmation, :phone, :fax,
                  :country, :state, :city, :address, :neighbourhood, :zipcode, :total_attendees,
                  :payment_agreement, :status_event
  attr_trimmed    :name, :state_inscription, :municipal_inscription, :contact_name, :contact_email,
                  :phone, :fax, :country, :state, :city, :address, :neighbourhood, :zipcode

  has_many :attendees
  has_many :course_attendances, :through => :attendees
  has_many :payment_notifications, :as => :invoicer

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
  
  validates_confirmation_of :contact_email
  
  after_initialize :generate_uri_token

  scope :for_conference, lambda { |c| select('DISTINCT registration_groups.*').joins(:attendees).where('attendees.conference_id = ?', c.id) }

  state_machine :status, :initial => :incomplete do
    event :complete do
      transition :incomplete => :complete
    end
    
    event :confirm do
      transition [:complete, :paid] => :confirmed
    end
    after_transition :to => :confirmed do |registration_group|
      registration_group.attendees.each(&:confirm)
    end

    event :pay do
      transition :complete => :paid
    end
    after_transition :to => :paid do |registration_group|
      registration_group.attendees.each(&:pay)
    end
    
    state :confirmed do
      validates_acceptance_of :payment_agreement
    end
    
    state :complete do
      validates_each :total_attendees do |record, attr, value|
        record.errors.add(attr, :incomplete, :total => value) if record.attendees.size < value
      end
    end
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