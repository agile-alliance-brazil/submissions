class Vote < ActiveRecord::Base
  attr_accessible :user_id, :logo_id, :user_ip

  belongs_to :user
  belongs_to :logo
  
  validates_presence_of :user_ip, :logo_id
  validates_existence_of :user, :logo, :message => :existence
  validates_uniqueness_of :user_id
  
  named_scope :for_user, lambda { |u| {:conditions => ['user_id = ?', u.to_i]} }
end