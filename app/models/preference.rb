# encoding: UTF-8
class Preference < ActiveRecord::Base
  attr_accessible :reviewer_id, :track_id, :audience_level_id, :accepted

  belongs_to :reviewer
  belongs_to :track
  belongs_to :audience_level
  has_one :user, :through => :reviewer
  
  validates_inclusion_of :accepted, :in => [true, false]
  validates_presence_of :audience_level_id, :if => :accepted?
  
  validates_existence_of :reviewer, :track
  validates_existence_of :audience_level, :if => :accepted?
  
  validates_each :track_id, :allow_blank => true, :if => :accepted? do |record, attr, value|
    record.errors.add(:accepted, :organizer_track) unless record.reviewer.can_review?(record.track)
    record.errors.add(attr, :invalid) if record.track.conference_id != record.reviewer.conference_id
  end
  validates_each :audience_level_id, :allow_blank => true, :if => :accepted? do |record, attr, value|
    record.errors.add(attr, :invalid) if record.audience_level.conference_id != record.reviewer.conference_id
  end
end