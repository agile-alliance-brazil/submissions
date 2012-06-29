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

  def in_author_confirmation_phase?
    (self.author_notification..self.author_confirmation).include? DateTime.now
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
    @dates ||= to_deadlines(DEADLINES)
  end

  def next_deadline(role)
    now = DateTime.now
    deadlines_for(role).select{|deadline| now < deadline.first}.first
  end

  private
  def deadlines_for(role)
    deadlines = case role.to_sym
    when :author
      [:presubmissions_deadline, :submissions_deadline, :author_notification, :author_confirmation]
    when :reviewer
      [:prereview_deadline, :review_deadline]
    when :organizer, :all
      DEADLINES
    end
    to_deadlines(deadlines)
  end

  def to_deadlines(deadlines)
    deadlines.map { |name| send(name) ? [send(name), name] : nil}.compact
  end
end
