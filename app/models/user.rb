class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :username, :email, :password,
                  :password_confirmation, :phone, :state, :city,
                  :organization, :website_url, :bio
  
  has_many :sessions, :foreign_key => 'author_id'
  
  validates_presence_of :first_name, :last_name, :phone, :state, :city, :bio
  
  acts_as_authentic do |config|
    config.merge_validates_format_of_email_field_options(:message => :email_format)
    config.merge_validates_format_of_login_field_options(:message => :username_format)
  end

  named_scope :search, lambda { |q| {:conditions => ["username LIKE ?", "#{q}%"]} }

  def full_name
    [self.first_name, self.last_name].join(' ')
  end
  
  def to_param
    username.blank? ? super : "#{id}-#{username.parameterize}"
  end
end
