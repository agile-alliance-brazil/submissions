class Organizer < ActiveRecord::Base
  attr_accessible :user_id, :track_id, :user_username
  attr_trimmed    :user_username

  belongs_to :user
  belongs_to :track
  
  validates_presence_of :track_id, :user_username
  validates_existence_of :user, :track
  validates_uniqueness_of :track_id, :scope => :user_id

  validates_each :user_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.user.nil?
  end
  
  after_save do
    user.add_role :organizer
    user.save(:validate => false)
  end
  
  after_update do
    if user_id_changed?
      old_user = User.find(user_id_was)
      if old_user.organized_tracks.empty?
        old_user.remove_role :organizer
        old_user.save(:validate => false)
      end
    end
  end
  
  after_destroy do
    if user.organized_tracks.empty?
      user.remove_role :organizer
      user.save(:validate => false)
    end
  end
  
  def user_username
    @user_username || user.try(:username)
  end
  
  def user_username=(username)
    @user_username = username.try(:strip)
    @user_username.tap do
      if @user_username.blank?
        self.user = nil
      else
        self.user = User.find_by_username(@user_username)
      end
    end
  end
end