# encoding: UTF-8
class Track < ActiveRecord::Base
  belongs_to :conference
  has_many :sessions
  has_many :track_ownerships, class_name: 'Organizer'
  has_many :organizers, through: :track_ownerships, source: :user

  validates :title, presence: true
  validates :description, presence: true

  scope :for_conference, lambda { |c| where(conference_id: c.id) }

  def experience_report?
    self.title == 'tracks.experience_reports.title'
  end
end
