# encoding: UTF-8
class SessionType < ActiveRecord::Base
  has_many :sessions
  belongs_to :conference

  validates_presence_of :title, :description

  scope :for_conference, lambda { |c| where(:conference_id => c.id) }

  %w(lightning_talk talk workshop hands_on experience_report).each do |type|
    define_method("#{type}?") do                   # def lightning_talk?
      self.title == "session_types.#{type}.title"  #   self.title == 'session_types.lightning_talk.title'
    end                                            # end
  end
end
