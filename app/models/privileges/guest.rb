# encoding: utf-8
class Privileges::Guest < Privileges::Base
  def privileges
    can([:read, :create], User)
    can(:update, User, id: @user.id)
    can(:read, Conference, visible: true)
    can(:read, Page, conference: { visible: true })
    can(:read, Session, conference: { visible: true })
    can(:read, Track, conference: { visible: true })
    can(:read, SessionType, conference: { visible: true })
    can(:read, AudienceLevel, conference: { visible: true })
    can(:read, ActsAsTaggableOn::Tag)
    can(:read, 'static_pages')
    can(:manage, 'password_resets')
    can([:read, :create], Comment)
    can([:edit, :update, :destroy], Comment, user_id: @user.id)
    can(:manage, 'accept_reviewers') do
      @conference.visible? && @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
    end
    can(:manage, 'reject_reviewers') do
      @conference.visible? && @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
    end
  end
end