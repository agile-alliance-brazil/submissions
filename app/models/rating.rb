# encoding: UTF-8
class Rating < ActiveRecord::Base
  validates :title, :presence => true
end
