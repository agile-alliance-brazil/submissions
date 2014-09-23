# encoding: UTF-8
class Organizer < ActiveRecord::Base
  attr_accessible :user_id, :track_id, :conference_id, :user_username
  attr_trimmed    :user_username

  attr_autocomplete_username_as :user

  belongs_to :user
  belongs_to :track
  belongs_to :conference

  validates :track_id, presence: true, existence: true, same_conference: true, uniqueness: {scope: [:conference_id, :user_id]}, allow_blank: true
  validates :conference_id, existence: true
  validates :user, existence: true

  scope :for_conference, lambda { |c| where(conference_id: c.id) }
  scope :for_user, lambda { |u| where(user_id: u.id) }

  def self.user_organizing_conference?(user, conference)
    !self.for_user(user).for_conference(conference).empty?
  end

  after_save do
    user.add_role :organizer
    user.save(validate: false)
  end

  after_update do
    if user_id_changed?
      old_user = User.find(user_id_was)
      if old_user.all_organized_tracks.empty?
        old_user.remove_role :organizer
        old_user.save(validate: false)
      end
    end
  end

  after_destroy do
    if user.all_organized_tracks.empty?
      user.remove_role :organizer
      user.save(validate: false)
    end
  end
end
