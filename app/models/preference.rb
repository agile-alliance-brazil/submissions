# encoding: UTF-8
class Preference < ActiveRecord::Base
  attr_accessible :reviewer_id, :track_id, :audience_level_id, :track, :audience_level, :accepted

  belongs_to :reviewer
  belongs_to :track
  belongs_to :audience_level
  has_one :user, :through => :reviewer
  
  validates :accepted, :inclusion => {:in => [true, false]}, :reviewer_track => {:if => :accepted?}
  validates :audience_level_id, :presence => true, :existence => true, :same_conference => {:target => :reviewer}, :if => :accepted?, :allow_blank => true
  validates :reviewer, :existence => true
  validates :track_id, :existence => true, :same_conference => {:target => :reviewer}, :if => :accepted?, :allow_blank => true
end