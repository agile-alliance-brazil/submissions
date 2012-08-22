# encoding: UTF-8
class Room < ActiveRecord::Base
  attr_accessible :name, :capacity, :conference_id

  belongs_to :conference
  has_many :activities

  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }
end
