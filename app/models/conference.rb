# frozen_string_literal: true

class Conference < ApplicationRecord
  has_attached_file :logo, styles: { medium: '300x80>', thumb: '75x20>' }
  validates_attachment :logo,
                       presence: true,
                       content_type: { content_type: %r{\Aimage/.*\Z} },
                       size: { in: 0..1.megabytes },
                       if: :visible?

  attr_trimmed :program_chair_user_username

  attr_autocomplete_username_as :program_chair_user

  acts_as_taggable_on :tags

  has_many :pages, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :audience_levels, dependent: :destroy
  has_many :session_types, dependent: :destroy

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

  # TODO: Define how this relationship should be shaped.
  def program_chair_user_username
    nil
  end

  def program_chair_user_username=(_user)
    nil
  end

  def default_page # TODO: tests
    home_page = Page.for_conference(self).with_path('home').includes(:translated_contents).first
    home_page = Page.for_conference(self).with_path('/').includes(:translated_contents).first if home_page.nil? # TODO: Legacy, remove
    home_page
  end

  def menu_links
    if pages.count.positive?
      links = []
      links << [I18n.t('title.home'), default_page] if default_page
      conference_pages = pages.includes(:translated_contents).where(show_in_menu: true).where.not(path: 'home').map do |p|
        [p.title, p]
      end
      links + conference_pages
    else
      [[I18n.t('title.home'), "/#{year}/home"], [I18n.t('title.guidelines'), "/#{year}/guidelines"]] # Legacy
    end
  end

  def supported_languages
    @supported_languages ||= self[:supported_languages].split(',').map(&:to_sym)
  end

  def supported_languages=(languages)
    @supported_languages = languages.reject(&:blank?).map(&:to_sym)
    self[:supported_languages] = @supported_languages.join(',')
  end

  def languages
    selected_languages = ActionView::Helpers::FormOptionsHelper::SUPPORTED_LANGUAGES.select do |(_name, code)|
      supported_languages.include?(code.to_sym)
    end
    selected_languages.map { |(name, code)| { name: name, code: code } }
  end

  def location_and_date
    if start_date.try(:year) != end_date.try(:year)
      "#{location}, #{I18n.localize(start_date, format: '%-d/%b, %Y')} - #{I18n.localize(end_date, format: '%-d/%b, %Y')}"
    elsif start_date.try(:month) != end_date.try(:month)
      "#{location}, #{I18n.localize(start_date, format: '%-d/%b')} - #{I18n.localize(end_date, format: '%-d/%b, %Y')}"
    elsif start_date || end_date
      "#{location}, #{I18n.localize(start_date, format: '%-d')}-#{I18n.localize(end_date, format: '%-d %b, %Y')}"
    else
      location.to_s
    end
  end

  def self.current
    where(visible: true).order('year desc').includes(pages: [:translated_contents]).first
  end

  def to_param
    year.to_s
  end

  def in_submission_phase?
    return false if submissions_open.nil? || submissions_deadline.nil?

    now = DateTime.now
    submissions_open <= now && now <= submissions_deadline
  end

  def has_early_review?
    presubmissions_deadline.present? && prereview_deadline.present?
  end

  def in_early_review_phase?
    return false unless has_early_review?

    now = DateTime.now
    presubmissions_deadline <= now && now <= prereview_deadline
  end

  def in_final_review_phase?
    return false if submissions_deadline.nil? || review_deadline.nil?

    now = DateTime.now
    submissions_deadline <= now && now <= review_deadline
  end

  def in_author_confirmation_phase?
    return false if author_notification.nil? || author_confirmation.nil?

    now = DateTime.now
    author_notification <= now && now <= author_confirmation
  end

  def in_voting_phase?
    return false if voting_deadline.blank?

    DateTime.now <= voting_deadline
  end

  DEADLINES = %i[
    call_for_papers
    submissions_open
    presubmissions_deadline
    prereview_deadline
    submissions_deadline
    author_notification
    author_confirmation
  ].freeze # review_deadline is out because it's an internal deadline

  def dates
    @dates ||= to_deadlines(DEADLINES)
  end

  def next_deadline(role)
    now = DateTime.now
    deadlines_for(role).select { |deadline| now < deadline.first }.first
  end

  def ideal_reviews_burn
    reviews_per_week = total_reviews_needed / [(weeks_to_work_in_reviews - 1), 1].max
    reviews_per_week += 1 if reviews_per_week.zero?
    ideal_remaining = [total_reviews_needed]
    (weeks_to_work_in_reviews - 1).times { ideal_remaining << [(ideal_remaining.last - reviews_per_week), 0].max }
    ideal_remaining
  end

  def actual_reviews_burn
    start_date = submissions_deadline.to_date
    end_date = [Time.zone.today, review_deadline.to_date].min
    reviews = Review.for_conference(self)
    weeks = start_date.step(end_date, 1.week / 1.day).to_a
    actual_remaining = [total_reviews_needed]
    weeks.map do |week_start|
      count = reviews.select { |review| week_start <= review.created_at && review.created_at < (week_start + 7.days) }.count
      actual_remaining << [(actual_remaining.last - count), 0].max
    end
    actual_remaining
  end

  private

  def weeks_to_work_in_reviews
    ((review_deadline - submissions_deadline).to_i / 86_400) / 7
  end

  def total_reviews_needed(reviews_per_session = 3)
    Session.active.for_conference(self).count * reviews_per_session
  end

  def deadlines_for(role)
    deadlines = case role.to_sym
                when :author
                  %i[presubmissions_deadline submissions_deadline author_notification author_confirmation]
                when :reviewer
                  %i[prereview_deadline review_deadline]
                when :organizer, :all
                  DEADLINES
                end
    to_deadlines(deadlines)
  end

  def to_deadlines(deadlines)
    deadlines.map { |name| send(name) ? [send(name), name] : nil }.compact
  end

  DATE_ORDERS = %i[call_for_papers submissions_open presubmissions_deadline prereview_deadline
                   submissions_deadline voting_deadline review_deadline author_notification author_confirmation
                   start_date end_date].freeze

  def date_orders
    DATE_ORDERS.reject { |d| send(d).nil? }.each_cons(2) do |(d1, d2)|
      date1 = send(d1)
      date2 = send(d2)
      next unless date1 >= date2
      next_date = I18n.t("conference.dates.#{d2}")
      error_message = I18n.t('errors.messages.cant_be_after', date: next_date)
      errors.add(d1, error_message)
    end
  end
end
