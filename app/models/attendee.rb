class Attendee < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :email_confirmation, :organization, :phone,
                  :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address,
                  :neighbourhood, :zipcode, :registration_type_id, :courses, :status_event, :conference_id,
                  :notes, :payment_agreement
  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :twitter_user, :address, :neighbourhood, :zipcode, :notes
  
  belongs_to :conference
  belongs_to :registration_type
  belongs_to :registration_group
  
  has_many :course_attendances
  
  validates_presence_of :first_name, :last_name, :email, :phone, :country, :city,
                        :gender, :address, :zipcode, :registration_type_id, :conference_id
  validates_presence_of :organization, :if => :student?
  validates_presence_of :cpf, :state, :if => Proc.new {|a| a.country == 'BR'}
  usar_como_cpf :cpf
  
  validates_existence_of :conference, :registration_type
  
  validates_length_of [:first_name, :last_name, :organization, :country, :state, :city, :neighbourhood, :twitter_user],
                      :maximum => 100, :allow_blank => true
  validates_length_of :badge_name, :maximum => 200, :allow_blank => true
  validates_length_of :address, :maximum => 300, :allow_blank => true
  validates_length_of :zipcode, :maximum => 10, :allow_blank => true
  validates_length_of :email, :within => 6..100, :allow_blank => true
  
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true
  validates_format_of :phone, :with => /\A[0-9\(\) .\-\+]+\Z/i, :allow_blank => true
  
  validates_inclusion_of :gender, :in => Gender.valid_values, :allow_blank => true
  
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
  validates_uniqueness_of :cpf, :allow_blank => true
  
  validates_confirmation_of :email

  validates_each :courses do |record, attr, courses|
    record.errors.add(attr, :compatible) if courses.size > 1 && !courses.all?(&:combine?)
    courses.each do |course|
      record.errors.add(attr, :limit_reached, :course => I18n.t(course.name)) if course.has_reached_limit?
    end
  end
  
  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }
  
  def self.sql_full_name
    case connection.instance_values["config"][:adapter]
    when "sqlite3" then "(first_name || ' ' || last_name)"
    else "CONCAT_WS(' ', first_name, last_name)"
    end
  end
  scope :with_full_name, select("*, #{Attendee.sql_full_name} as full_name")
  
  scope :search, lambda { |q| where("#{Attendee.sql_full_name} LIKE ?", "%#{q}%")}
  
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
    
    state :confirmed do
      validates_acceptance_of :payment_agreement
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
    base_price = base_price(datetime)
    
    periods = RegistrationPeriod.for(datetime)
    period = periods.first
    
    course_prices = course_attendances.map { |ca| period.price_for_course(ca.course) }
    
    [base_price, *course_prices].sum
  end

  def base_price(datetime)
    periods = RegistrationPeriod.for(datetime)
    
    period = periods.first
    period = periods.last if pre_registered?

    period.price_for_registration_type(registration_type)
  end
  
  def pre_registered?
    pre_registration = PreRegistration.registered(email).first
    return (not pre_registration.nil?) && (not pre_registration.used?)
  end
  
  def courses=(course_ids)
    course_ids.each do |id|
      self.course_attendances.build(:course_id => id) unless id.blank?
    end
  end
  
  def courses
    course_attendances.map { |attendance| attendance.course }
  end
  
  def courses_summary
    courses.map {|c| I18n.t(c.name)}.join(',')
  end
end