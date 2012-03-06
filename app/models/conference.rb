# encoding: UTF-8
class Conference < ActiveRecord::Base
  has_many :tracks
  has_many :audience_levels
  has_many :session_types

  def self.current
    @current_conference ||= Conference.order('year desc').first
  end

  def to_param
    year.to_s
  end

  def dates
    @dates ||= [:call_for_papers, :submissions_open, :submissions_deadline, :author_notification, :author_confirmation].map do |name|
      [send(name).to_date, name]
    end
  end
end
