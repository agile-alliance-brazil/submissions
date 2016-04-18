# encoding: UTF-8
class Conference < ActiveRecord::Base
  has_attached_file :logo, styles: { medium: '300x80>', thumb: '75x20>' }
  validates_attachment :logo,
    presence: true,
    content_type: {content_type: /\Aimage\/.*\Z/},
    size: { in: 0..500.kilobytes },
    if: :visible?

  attr_trimmed    :program_chair_user_username

  attr_autocomplete_username_as :program_chair_user

  has_many :pages
  has_many :tracks
  has_many :audience_levels
  has_many :session_types

  validates :name, presence: true
  validates :year, presence: true, constant: { on: :update }
  validates :location, presence: true, if: :visible?
  validates :start_date, presence: true, if: :visible?
  validates :end_date, presence: true, if: :visible?
  validates :submissions_open, presence: true, if: :visible?
  validates :submissions_deadline, presence: true, if: :visible?
  validates :review_deadline, presence: true, if: :visible?
  validates :author_notification, presence: true, if: :visible?
  validates :author_confirmation, presence: true, if: :visible?

  validate :date_orders

  # TODO: Allow for logo upload
  # TODO: Define how this relationship should be shaped.
  def program_chair_user_username
    nil
  end

  def program_chair_user_username=(user)
    nil
  end

  def location_and_date
    if start_date.try(:year) != end_date.try(:year)
      "#{location}, #{start_date.try(:strftime, '%-d/%b, %Y')} - #{end_date.try(:strftime, '%-d/%b, %Y')}"
    elsif start_date.try(:month) != end_date.try(:month)
      "#{location}, #{start_date.try(:strftime, '%-d/%b')} - #{end_date.try(:strftime, '%-d/%b, %Y')}"
    elsif start_date || end_date
      "#{location}, #{start_date.try(:strftime, '%-d')}-#{end_date.try(:strftime, '%-d %b, %Y')}"
    else
      "#{location}"
    end
  end

  def self.current
    order('year desc').first
  end

  def to_param
    year.to_s
  end

  def in_submission_phase?
    return false if self.submissions_open.nil? || self.submissions_deadline.nil?

    now = DateTime.now
    self.submissions_open <= now && now <= self.submissions_deadline
  end

  def has_early_review?
    self.presubmissions_deadline.present? && self.prereview_deadline.present?
  end

  def in_early_review_phase?
    return false unless has_early_review?

    now = DateTime.now
    self.presubmissions_deadline <= now && now <= self.prereview_deadline
  end

  def in_final_review_phase?
    return false if self.submissions_deadline.nil? || self.review_deadline.nil?

    now = DateTime.now
    self.submissions_deadline <= now && now <= self.review_deadline
  end

  def in_author_confirmation_phase?
    return false if self.author_notification.nil? || self.author_confirmation.nil?

    now = DateTime.now
    self.author_notification <= now && now <= self.author_confirmation
  end

  def in_voting_phase?
    return false if self.voting_deadline.blank?

    DateTime.now <= self.voting_deadline
  end

  DEADLINES = %i(
    call_for_papers
    submissions_open
    presubmissions_deadline
    prereview_deadline
    submissions_deadline
    author_notification
    author_confirmation
  ) # review_deadline is out because it's an internal deadline

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
      %i(presubmissions_deadline submissions_deadline author_notification author_confirmation)
    when :reviewer
      %i(prereview_deadline review_deadline)
    when :organizer, :all
      DEADLINES
    end
    to_deadlines(deadlines)
  end

  def to_deadlines(deadlines)
    deadlines.map { |name| send(name) ? [send(name), name] : nil}.compact
  end

  DATE_ORDERS = %i(call_for_papers submissions_open presubmissions_deadline prereview_deadline
    submissions_deadline voting_deadline review_deadline author_notification author_confirmation
    start_date end_date)

  def date_orders
    DATE_ORDERS.reject{|d| send(d).nil?}.each_cons(2) do |(d1, d2)|
      date1 = send(d1)
      date2 = send(d2)
      if date1 >= date2
        next_date = I18n.t("conference.dates.#{d2}")
        error_message = I18n.t('errors.messages.cant_be_after', date: next_date)
        errors.add(d1, error_message)
      end
    end
  end
end
