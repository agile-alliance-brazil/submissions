# encoding: UTF-8
class Room < ActiveRecord::Base
  attr_accessible :name, :capacity, :conference_id

  belongs_to :conference
  has_many :activities
end
