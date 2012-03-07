# encoding: UTF-8
class User < ActiveRecord::Base
  include Authorization

  devise :database_authenticatable, :registerable, :recoverable, :encryptable, :trackable, :validatable

  attr_accessible :first_name, :last_name, :username, :email, :password,
                  :password_confirmation, :phone, :country, :state, :city,
                  :organization, :website_url, :bio, :wants_to_submit, :default_locale, :twitter_username
  attr_trimmed    :first_name, :last_name, :username, :email, :twitter_username,
                  :phone, :state, :city, :organization, :website_url, :bio
  
  has_many :sessions, :foreign_key => 'author_id'
  has_many :organizers
  has_many :all_organized_tracks, :through => :organizers, :source => :track
  has_many :reviewers
  has_many :reviews, :foreign_key => 'reviewer_id'
  
  validates_presence_of :first_name, :last_name
  validates_presence_of [:phone, :country, :city, :bio], :if => :author?
  validates_presence_of :state, :if => Proc.new {|u| u.author? && u.in_brazil?}
  
  validates_length_of [:first_name, :last_name, :phone, :city, :organization, :website_url], :maximum => 100, :allow_blank => true
  validates_length_of :bio, :maximum => 1600, :allow_blank => true
  validates_length_of :username, :within => 3..30
  validates_length_of :email, :within => 6..100, :allow_blank => true

  validates_format_of :phone, :with => /\A[0-9\(\) .\-\+]+\Z/i, :if => :author?, :allow_blank => true
  validates_format_of :username, :with => /\A\w[\w\.+\-_@ ]+$/, :message => :username_format

  validates_uniqueness_of :username, :case_sensitive => false, :if => :username_changed?
  
  validates_each :username, :on => :update do |record, attr, value|
    record.errors.add(attr, :constant) if record.username_changed?
  end
  
  before_validation do |user|
    user.twitter_username = user.twitter_username[1..-1] if user.twitter_username =~ /^@/
  end

  scope :search, lambda { |q| where("username LIKE ?", "%#{q}%") }

  def organized_tracks(conference)
    Track.joins(:track_ownerships).where(:organizers => {
        :conference_id => conference.id,
        :user_id => self.id
    })
  end

  def preferences(conference)
    Preference.joins(:reviewer).where(:reviewers => {
        :conference_id => conference.id,
        :user_id => self.id
    })
  end
  
  def sessions_for_conference(conference)
    Session.for_user(self.id).for_conference(conference)
  end

  # Overriding role check to take current conference into account
  def reviewer_with_conference?
    reviewer_without_conference? && Reviewer.user_reviewing_conference?(self, Conference.current)
  end
  alias_method_chain :reviewer?, :conference

  # Overriding role check to take current conference into account
  def organizer_with_conference?
    organizer_without_conference? && Organizer.user_organizing_conference?(self, Conference.current)
  end
  alias_method_chain :organizer?, :conference

  def full_name
    [self.first_name, self.last_name].join(' ')
  end
  
  def to_param
    username.blank? ? super : "#{id}-#{username.parameterize}"
  end
  
  def in_brazil?
    self.country == "BR"
  end

  def wants_to_submit
    author?
  end
  
  def wants_to_submit=(wants_to_submit)
    self.add_role('author') if wants_to_submit == '1'
  end
  
  def has_approved_session?(conference)
    Session.for_user(self.id).for_conference(conference).with_state(:accepted).count > 0
  end
end
