class User < ActiveRecord::Base
  include Authorization
  
  attr_accessible :first_name, :last_name, :username, :email, :password,
                  :password_confirmation, :phone, :country, :state, :city,
                  :organization, :website_url, :bio, :wants_to_submit
  attr_trimmed    :first_name, :last_name, :username, :email,
                  :phone, :state, :city, :organization, :website_url, :bio
  
  has_many :sessions, :foreign_key => 'author_id'
  has_many :organizers
  has_many :organized_tracks, :through => :organizers, :source => :track
  has_one :reviewer
  has_many :preferences, :through => :reviewer, :source => :accepted_preferences
  has_many :reviews, :foreign_key => 'reviewer_id'
  
  validates_presence_of :first_name, :last_name
  validates_presence_of [:phone, :country, :city, :bio], :unless => :guest?
  validates_presence_of :state, :if => Proc.new {|u| !u.guest? && u.in_brazil?}
  
  validates_length_of [:first_name, :last_name, :phone, :city, :organization, :website_url], :maximum => 100, :allow_blank => true
  validates_length_of :bio, :maximum => 1600, :allow_blank => true
  
  validates_format_of :phone, :with => /\A[0-9\(\) .\-\+]+\Z/i, :unless => :guest?, :allow_blank => true
  
  validates_each :username, :on => :update do |record, attr, value|
    record.errors.add(attr, :constant) if record.username_changed?
  end
  
  acts_as_authentic do |config|
    config.merge_validates_format_of_email_field_options(:message => :email_format)
    config.merge_validates_format_of_login_field_options(:message => :username_format)
    config.merge_validates_length_of_login_field_options(:within => 3..30)
  end

  named_scope :search, lambda { |q| {:conditions => ["username LIKE ?", "%#{q}%"]} }
  
  def full_name
    [self.first_name, self.last_name].join(' ')
  end
  
  def to_param
    username.blank? ? super : "#{id}-#{username.parameterize}"
  end
  
  def in_brazil?
    self.country == "BR"
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    EmailNotifications.deliver_password_reset_instructions(self)
  end
  
  def wants_to_submit
    author?
  end
  
  def wants_to_submit=(wants_to_submit)
    self.add_role('author') if wants_to_submit == '1'
  end
end
