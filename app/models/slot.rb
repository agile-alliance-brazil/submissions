# encoding: UTF-8
class Slot
  include Forwardable

  attr_reader :start, :deadline

  def initialize(start, deadline)
    @start = start
    @deadline = deadline
  end

  def ==(other)
    start == other.start && deadline == other.deadline
  end

  def include?(time)
    start <= time && time < deadline
  end

  def duration
    deadline - start
  end

  def to_s
    "#{start}...#{deadline}"
  end

  class << self
    def from(start, duration)
      self.new(start, start + duration)
    end

    def divide(start, finish, interval)
      slots = []
      while start < finish
        interval = (finish - start) > interval ? interval : (finish - start)
        slots << Slot.from(start, interval)
        start += interval
      end
      slots
    end
  end
end