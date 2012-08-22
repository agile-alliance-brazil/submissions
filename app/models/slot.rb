# encoding: UTF-8
class Slot
  include Forwardable

  attr_reader :range
  protected :range

  delegate :end, :include?, :to => :@range

  def initialize(range)
    @range = range
  end

  def start
    @range.begin
  end

  def ==(other)
    @range == other.range
  end

  def duration
    @range.end - @range.begin
  end

  class << self
    def from(start, duration)
      self.new((start...(start + duration)))
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