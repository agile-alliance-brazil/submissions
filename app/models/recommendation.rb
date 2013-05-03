# encoding: UTF-8
class Recommendation < ActiveRecord::Base
  validates :title, :presence => true
  
  has_many :reviews
end
