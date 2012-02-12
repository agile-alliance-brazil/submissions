# encoding: UTF-8
class PreRegistration < ActiveRecord::Base
  belongs_to :conference
  
  scope :registered, lambda {|email| where('UPPER(email) = UPPER(?)', email) }
end
