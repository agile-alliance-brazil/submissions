# encoding: UTF-8
class Track < ActiveRecord::Base

  validates_presence_of :title, :description
  
  has_many :sessions
  has_many :track_ownerships, :class_name => 'Organizer'
  has_many :organizers, :through => :track_ownerships, :source => :user
end
