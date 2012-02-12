# encoding: UTF-8
class Slot < ActiveRecord::Base
  
  validates_presence_of :start_at, :end_at
  
  belongs_to :session
  belongs_to :track
end
