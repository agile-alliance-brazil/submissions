# encoding: UTF-8
class SessionType < ActiveRecord::Base
  has_many :sessions
  belongs_to :conference
  serialize :valid_durations, Array

  validates :title, :presence => true
  validates :description, :presence => true

  scope :for_conference, lambda { |c| where(:conference_id => c.id) }

  def self.all_titles
    self.select(:title).uniq.map do |session_type|
      session_type.title.match(/session_types\.(\w+)\.title/)[1]
    end
  end

  all_titles.each do |type|
    define_method("#{type}?") do                   # def lightning_talk?
      self.title == "session_types.#{type}.title"  #   self.title == 'session_types.lightning_talk.title'
    end                                            # end
  end
end
