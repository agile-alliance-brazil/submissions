# encoding: UTF-8
class AudienceLevel < ActiveRecord::Base
  
  validates_presence_of :title, :description

  has_many :sessions
  
end
