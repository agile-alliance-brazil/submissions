# encoding: UTF-8
class Outcome < ActiveRecord::Base
  validates :title, :presence => true
  
  has_many :review_decisions
end
