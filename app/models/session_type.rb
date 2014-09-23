# encoding: UTF-8
class SessionType < ActiveRecord::Base
  has_many :sessions
  belongs_to :conference
  serialize :valid_durations, Array

  validates :title, presence: true
  validates :description, presence: true

  scope :for_conference, lambda { |c| where(conference_id: c.id) }

  def self.all_titles
    self.select(:title).uniq.map do |session_type|
      session_type.title.match(/session_types\.(\w+)\.title/).try(:[], 1)
    end
  end

  def respond_to_missing_with_title?(method_sym, include_private = false)
    is_title_check_method?(method_sym) || super
  end

  def method_missing(method_sym, *arguments, &block)
    if is_title_check_method?(method_sym)
      title_matches(method_sym)
    else
      super
    end
  end

  private

  def title_matches(method_sym)
    title_name = method_sym.to_s.gsub(/\?$/,'')
    self.title == "session_types.#{title_name}.title"
  end

  def is_title_check_method?(method_sym)
    method_sym.to_s.ends_with?('?') &&
      SessionType.all_titles.
        map{|title| "#{title}?"}.
        include?(method_sym.to_s)
  end
end
