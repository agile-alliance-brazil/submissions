class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new # guest
    
    can :read, :all
    can(:manage, UserSession)
    can(:create, User)
    can(:update, User) { |u| u == user }
    
    if user.admin?
      can :manage, :all
    elsif user.author?
      can :create, Session
      can :update, Session do |session|
        session.try(:author) == user || session.try(:second_author) == user
      end
    end
  end
end