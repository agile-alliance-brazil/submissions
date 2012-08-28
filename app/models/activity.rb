# encoding: UTF-8
class Activity < ActiveRecord::Base
  attr_accessible :detail_type, :detail_id, :start_at, :end_at, :room_id

  belongs_to :room
  belongs_to :detail, :polymorphic => true

  scope :for_conference, lambda { |c|
    year = Date.strptime(c.year.to_s, '%Y')
    where(:start_at => (year.beginning_of_year...year.end_of_year))
  }

  def date
    start_at.to_date
  end

  def starts_in?(slot)
    slot.start == start_at
  end

  def in_room?(room)
    room == self.room
  end

  def wbma?
    room.id == 6
  end

  def slots_remaining(slot)
    ((end_at - start_at) / slot.duration).ceil
  end

  def keynote?
    detail.is_a?(GuestSession) && detail.keynote?
  end

  def all_hands?
    detail.is_a?(AllHands)
  end

  def all_rooms?
    keynote? || all_hands?
  end

  def css_classes
    ["activity"].tap do |classes|
      classes << (keynote? ? "keynote" : detail.class.to_s.underscore)
    end
  end
end