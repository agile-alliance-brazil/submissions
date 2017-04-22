# encoding: utf-8
# frozen_string_literal: true

module Privileges
  class Guest < Privileges::Base
    def privileges
      can(%i[read create], User)
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
      can(%i[read create], Comment)
      can(%i[edit update destroy], Comment, user_id: @user.id)
      can(:manage, 'accept_reviewers') do
        @conference.visible? && @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
      end
      can(:manage, 'reject_reviewers') do
        @conference.visible? && @reviewer.present? && @reviewer.user == @user && @reviewer.invited?
      end
    end
  end
end
