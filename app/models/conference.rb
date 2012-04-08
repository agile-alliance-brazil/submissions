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

  DEADLINES = [
    :call_for_papers,
    :submissions_open,
    :presubmissions_deadline,
    :prereview_deadline,
    :submissions_deadline,
    # :review_deadline, # Internal deadline
    :author_notification,
    :author_confirmation
  ]

  def dates
    @dates ||= DEADLINES.map { |name| send(name) ? [send(name).to_date, name] : nil}.compact
  end

  def next_deadline
    now = DateTime.now
    dates.select{|date_map| now < date_map.first}.first
  end

  def in_submission_phase?
    (self.submissions_open..self.submissions_deadline).include? DateTime.now
  end

  def in_early_review_phase?
    return false if self.prereview_deadline.blank?
    (self.presubmissions_deadline..self.prereview_deadline).include? DateTime.now
  end

  def in_final_review_phase?
    (self.submissions_deadline..self.review_deadline).include? DateTime.now
  end
end
