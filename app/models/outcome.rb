# encoding: UTF-8
class Outcome < ActiveRecord::Base
  validates_presence_of :title
  
  has_many :review_decisions
end
