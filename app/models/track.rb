# encoding: UTF-8
class Track < ActiveRecord::Base
  validates_presence_of :title, :description

  belongs_to :conference
  has_many :sessions
  has_many :track_ownerships, :class_name => 'Organizer'
  has_many :organizers, :through => :track_ownerships, :source => :user
  
  scope :for_conference, lambda { |c| where(:conference_id => c.id) }
end
