# encoding: UTF-8
class RegistrationPrice < ActiveRecord::Base
  belongs_to :registration_type
  belongs_to :registration_period
  
  scope :for, lambda { |period, type| where('registration_type_id = ? AND registration_period_id = ?', type.id, period.id) }
end
