# encoding: utf-8
class Privileges::Guest < Privileges::Base
  def privileges
    can([:read, :create], User)
    can(:update, User, id: @user.id)
    can(:read, Conference)
    can(:read, Session)
    can(:read, Track)
    can(:read, SessionType)
    can(:read, AudienceLevel)
    can(:read, ActsAsTaggableOn::Tag)
    can(:read, 'static_pages')
    can(:manage, 'password_resets')
    can([:read, :create], Comment)
    can([:edit, :update, :destroy], Comment, user_id: @user.id)
    can(:manage, 'accept_reviewers') do
      @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
    end
    can(:manage, 'reject_reviewers') do
      @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
    end
  end
end