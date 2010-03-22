class Reviewer < ActiveRecord::Base
  attr_accessible :user_id, :user_username
  attr_trimmed    :user_username

  belongs_to :user
  has_many :evaluations
  
  validates_presence_of :user_username
  validates_existence_of :user, :message => :existence
  validates_uniqueness_of :user_id

  validates_each :user_username, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, :existence) if record.user.nil?
  end
  
  def after_validation
    if errors.on(:user_id)
      errors.on(:user_id).each { |error| errors.add(:user_username, error) }
    end
  end
  
  state_machine :initial => :created do
    after_transition :on => :invite do |reviewer|
      EmailNotifications.deliver_reviewer_invitation(reviewer)
    end
    
    after_transition :on => :accept do |reviewer|
      reviewer.user.add_role :reviewer
      reviewer.user.save!
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
  end
  
  def after_create
    invite
  end
  
  def after_destroy
    user.remove_role :reviewer
    user.save!
  end
  
  def user_username
    @user_username || user.try(:username)
  end
  
  def user_username=(username)
    @user_username = username.try(:strip)
    returning @user_username do
      if @user_username.blank?
        self.user = nil
      else
        self.user = User.find_by_username(@user_username)
      end
    end
  end
end