class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :username, :email, :password,
                  :password_confirmation, :phone, :state, :city,
                  :organization, :website_url, :bio
  
  validates_presence_of :first_name, :last_name, :phone, :state, :city, :bio
  
  acts_as_authentic
  
  def full_name
    [self.first_name, self.last_name].join(' ')
  end
end
