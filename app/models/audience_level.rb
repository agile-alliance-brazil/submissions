# encoding: UTF-8
class AudienceLevel < ActiveRecord::Base
  has_many :sessions
  belongs_to :conference

  validates :title, presence: true
  validates :description, presence: true

  scope :for_conference, lambda { |c| where(conference_id: c.id) }
end
