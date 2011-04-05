class RegistrationType < ActiveRecord::Base
  belongs_to :conference
  has_many :registration_prices
  
  scope :without_group, where('id <> ?', 2)
end