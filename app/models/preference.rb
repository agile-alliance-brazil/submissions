class Preference < ActiveRecord::Base
  attr_accessible :reviewer_id, :track_id, :audience_level_id, :accepted

  belongs_to :reviewer
  belongs_to :track
  belongs_to :audience_level
  has_one :user, :through => :reviewer
  
  validates_inclusion_of :accepted, :in => [true, false]
  validates_presence_of :audience_level_id, :if => :accepted?
  
  validates_existence_of :reviewer, :track, :message => :existence
  validates_existence_of :audience_level, :if => :accepted?, :message => :existence
end