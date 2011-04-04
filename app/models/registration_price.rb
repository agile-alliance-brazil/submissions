class RegistrationPrice < ActiveRecord::Base
  belongs_to :registration_type
  belongs_to :registration_period
end