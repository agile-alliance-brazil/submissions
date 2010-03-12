class Organizer < ActiveRecord::Base
  attr_accessible :user_id, :track_id

  belongs_to :user
  belongs_to :track
  
  validates_presence_of :user_id, :track_id
  validates_existence_of :user, :track, :message => :existence
  
  def after_create
    user.add_role :organizer
  end
  
  def after_destroy
    user.remove_role :organizer if user.organized_tracks.empty?
  end
end