class Reviewer < ActiveRecord::Base
  attr_accessible :user_id, :conference_id, :user_username, :preferences_attributes,
                  :reviewer_agreement, :state_event
  attr_trimmed    :user_username

  belongs_to :user
  belongs_to :conference
  has_many :preferences
  has_many :accepted_preferences, :class_name => 'Preference', :conditions => ['preferences.accepted = ?', true]
  
  accepts_nested_attributes_for :preferences
  
  validates_presence_of :user_username, :conference_id
  validates_existence_of :user, :conference
  validates_uniqueness_of :user_id, :scope => :conference_id

  validates_each :user_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.user.nil?
  end

  scope :for_conference, lambda { |c| where('conference_id = ?', c.id) }

  scope :for_user, lambda { |u| where('user_id = ?', u.id) }

  scope :accepted, lambda { where('state = ?', :accepted) }

  def self.user_reviewing_conference?(user, conference)
    !self.for_user(user).for_conference(conference).accepted.empty?
  end

  after_validation do
    if !errors[:user_id].empty?
      errors[:user_id].each { |error| errors.add(:user_username, error) }
    end
  end
  
  state_machine :initial => :created do
    after_transition :on => :invite do |reviewer|
      EmailNotifications.reviewer_invitation(reviewer).deliver
    end
    
    after_transition :on => :accept do |reviewer|
      reviewer.user.add_role :reviewer
      reviewer.user.save(:validate => false)
    end
    
    event :invite do
      transition [:created, :invited] => :invited
    end

    event :accept do
      transition :invited => :accepted
    end

    event :reject do
      transition :invited => :rejected
    end
    
    state :accepted do
      validate do |reviewer|
        if reviewer.preferences.select {|p| p.accepted?}.empty?
          reviewer.errors.add(:base, :preferences)
        end
      end
      validates_acceptance_of :reviewer_agreement
    end
  end
  
  after_create do
    invite
  end
  
  after_destroy do
    user.remove_role :reviewer
    user.save(:validate =>false)
  end
  
  def can_review?(track)
    !user.organized_tracks(self.conference).include?(track)
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