class Ability
  include CanCan::Ability
  
  def initialize(user, params={})
    user ||= User.new # guest
    
    alias_action :edit, :update, :destroy, :to => :modify
    
    can(:read, :all) do |object_class, obj|
      object_class != Organizer &&
      object_class != Reviewer &&
      object_class != Review &&
      obj != "organizer_sessions" &&
      obj != "reviewer_sessions" &&
      obj != "reviews_listing"
    end
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
    can(:update, Reviewer) do |reviewer|
      reviewer.try(:user) == user && reviewer.invited?
    end
    
    if user.admin?
      can(:manage, :all)
    end
    if user.author?
      can(:create, Session) do
        Time.zone.now <= Time.zone.local(2010, 3, 7, 23, 59, 59)
      end
      can(:update, Session) do |session|
        is_author(session, user) && Time.zone.now <= Time.zone.local(2010, 3, 7, 23, 59, 59)
      end
      can(:index, Review) do
        is_author(find_session(params), user)
      end
    end
    if user.organizer?
      can(:manage, Reviewer)
      can(:read, "organizer_sessions")
      can(:cancel, Session) do |session|
        session.can_cancel? && user.organized_tracks.include?(session.track)
      end
      can(:show, Review)
      can(:index, Review) do
        session = find_session(params)
        user.organized_tracks.include?(session.try(:track))
      end
    end
    if user.reviewer?
      can(:read, "reviewer_sessions")
      can(:show, Review) { |review| review.reviewer == user }
      can(:create, Review) do |_, session|
        session = find_session(params) if session.nil?
        Session.for_reviewer(user).include?(session)
      end
      can(:read, 'reviews_listing')
      can(:reviewer, 'reviews_listing')
    end
  end
  
  private
  
  def find_session(params)
    Session.find(params[:session_id]) if !params[:session_id].blank?
  end
  
  def is_author(session, user)
    session.try(:author) == user || session.try(:second_author) == user
  end
end