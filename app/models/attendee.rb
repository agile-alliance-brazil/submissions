class Attendee < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :email_confirmation, :organization, :phone,
                  :country, :state, :city, :badge_name, :cpf, :gender, :twitter_user, :address,
                  :neighbourhood, :zipcode, :registration_type_id, :courses, :status_event, :conference_id,
                  :notes, :payment_agreement, :registration_date
  attr_trimmed    :first_name, :last_name, :email, :organization, :phone, :country, :state, :city,
                  :badge_name, :twitter_user, :address, :neighbourhood, :zipcode, :notes
  
  belongs_to :conference
  belongs_to :registration_type
  belongs_to :registration_group
  
  has_many :course_attendances
  has_many :payment_notifications
  
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
    record.new_courses.each do |course|
      record.errors.add(attr, :limit_reached, :course => I18n.t(course.name)) if course.has_reached_limit?
    end
  end
  
  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }

  after_initialize :set_default_registration_date, :generate_uri_token

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
      transition [:pending, :paid] => :confirmed
    end

    event :pay do
      transition :pending => :paid
    end
    
    state :confirmed do
      validates_acceptance_of :payment_agreement
    end
    
    after_transition any => :confirmed do |attendee|
      begin
        EmailNotifications.registration_confirmed(attendee).deliver
      rescue => ex
        HoptoadNotifier.notify(ex)
      end
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
  
  def registration_fee
    course_prices = course_attendances.map { |ca| course_registration_period.price_for_course(ca.course) }
    
    [base_price, *course_prices].sum
  end

  def base_price
    registration_period.price_for_registration_type(registration_type)
  end
  
  def course_registration_period
    periods = RegistrationPeriod.for(self.registration_date)
    periods.first
  end
  
  def registration_period
    periods = RegistrationPeriod.for(self.registration_date)
    pre_registered? ? periods.last : periods.first
  end
  
  def pre_registered?
    pre_registration = PreRegistration.registered(email).first
    pre_registration && !pre_registration.used?
  end
  
  def courses=(course_ids)
    course_ids.each do |id|
      self.course_attendances.build(:course_id => id) unless id.blank?
    end
  end
  
  def courses
    course_attendances.map { |attendance| attendance.course }
  end
  
  def registered_courses
    CourseAttendance.where(:attendee_id => self.id).joins(:course).all.map(&:course)
  end
  
  def new_courses
    courses - registered_courses
  end
  
  def courses_summary
    courses.map {|c| I18n.t(c.name)}.join(',')
  end

  def self.generate_token(column)
    loop do
      token = ActiveSupport::SecureRandom.hex(5)
      break token unless find(:first, :conditions => { column => token })
    end
  end

  private
  def set_default_registration_date
    self.registration_date ||= Time.zone.now
  end
  
  def generate_uri_token
    self.uri_token ||= Attendee.generate_token(:uri_token)
  end
end