# encoding: UTF-8
class Activity < ActiveRecord::Base
  attr_accessible :detail_type, :detail_id, :start_at, :end_at, :room_id

  belongs_to :room
  belongs_to :detail, :polymorphic => true

  def date
    start_at.to_date
  end

  def starts_in?(slot, room)
    slot.start == start_at && room == self.room
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