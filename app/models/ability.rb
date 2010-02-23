class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new # guest
    
    alias_action :edit, :update, :destroy, :to => :modify
    
    can(:read, :all)
    can(:manage, UserSession)
    can(:create, User)
    can(:update, User) { |u| u == user }
    can(:create, Comment)
    can(:modify, Comment) { |c| c.user == user }
    can(:create, Vote) do
      first_vote = Vote.for_user(user.id).count == 0
      first_vote && Time.zone.now <= Time.zone.local(2010, 3, 7, 23, 59, 59)
    end
    can(:update, Vote) do |vote|
      is_voter = vote.try(:user) == user
      is_voter && Time.zone.now <= Time.zone.local(2010, 3, 7, 23, 59, 59)
    end
    can(:new, Vote)
    
    if user.admin?
      can :manage, :all
    elsif user.author?
      can :create, Session
      can :update, Session do |session|
        is_author = session.try(:author) == user || session.try(:second_author) == user
        is_author && Time.zone.now <= Time.zone.local(2010, 2, 28, 23, 59, 59)
      end
    end
  end
end